defmodule CodeSponsor.PropertiesTest do
  use CodeSponsor.DataCase

  alias CodeSponsor.Properties

  setup do
    user = CodeSponsor.Support.Fixture.generate(:user)
    property = CodeSponsor.Support.Fixture.generate(:property)
    property = CodeSponsor.Repo.get!(CodeSponsor.Schema.Property, property.id)
    {:ok, %{user: user, property: property}}
  end

  describe "properties" do
    alias CodeSponsor.Schema.Property

    @valid_attrs %{description: "some description", name: "some name", property_type: 42, url: "some url"}
    @update_attrs %{description: "some updated description", name: "some updated name", property_type: 43, url: "some updated url"}
    @invalid_attrs %{description: nil, name: nil, property_type: nil, url: nil}

    test "list_properties/0 returns all properties", %{property: property} do
      assert Properties.list_properties() == [property]
    end

    test "get_property!/1 returns the property with given id", %{property: property} do
      assert Properties.get_property!(property.id) == property
    end

    test "create_property/1 with valid data creates a property", %{user: user} do
      valid_attrs = @valid_attrs |> Map.put(:user, user)
      {:ok, %Property{} = property} = Properties.create_property(valid_attrs)
      assert property.description == "some description"
      assert property.name == "some name"
      assert property.property_type == 42
      assert property.url == "some url"
      assert property.user_id == user.id
    end

    test "create_property/1 without a user raises ecto changeset error"do
      assert {:error, %Ecto.Changeset{} = changeset} = Properties.create_property(@valid_attrs)
      assert changeset.errors == [user_id: {"can't be blank", [validation: :required]}]
    end

    test "create_property/1 with invalid data returns error changeset" do
      {:error, changeset} = Properties.create_property(@invalid_attrs)
      assert changeset.__struct__ == Ecto.Changeset
    end

    test "update_property/2 with valid data updates the property" do
      property = CodeSponsor.Support.Fixture.generate(:property)
      assert {:ok, property} = Properties.update_property(property, @update_attrs)
      assert %Property{} = property
      assert property.description == "some updated description"
      assert property.name == "some updated name"
      assert property.property_type == 43
      assert property.url == "some updated url"
    end

    test "update_property/2 with invalid data returns error changeset", %{property: property} do
      assert {:error, %Ecto.Changeset{}} = Properties.update_property(property, @invalid_attrs)
      assert property == Properties.get_property!(property.id)
    end

    test "delete_property/1 deletes the property" do
      property = CodeSponsor.Support.Fixture.generate(:property)
      assert {:ok, %Property{}} = Properties.delete_property(property)
      assert_raise Ecto.NoResultsError, fn -> Properties.get_property!(property.id) end
    end

    test "change_property/1 returns a property changeset", %{property: property} do
      assert %Ecto.Changeset{} = Properties.change_property(property)
    end
  end
end
