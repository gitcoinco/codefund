defmodule CodeFund.PropertiesTest do
  use CodeFund.DataCase
  alias CodeFund.Properties
  import CodeFund.Factory

  setup do
    property = insert(:property, %{status: 1, property_type: 1})
    user = insert(:user)
    {:ok, %{user: user, property: property}}
  end

  describe "properties" do
    alias CodeFund.Schema.Property

    @valid_attrs %{
      description: "some description",
      name: "some name",
      property_type: 42,
      url: "http://google.com",
      programming_languages: ["Ruby"],
      topic_categories: ["Databases"],
      language: "English"
    }
    @update_attrs %{
      description: "some updated description",
      name: "some updated name",
      property_type: 43,
      url: "http://aol.com"
    }
    @invalid_attrs %{description: nil, name: nil, property_type: nil, url: nil}

    test "list_properties/0 returns all properties", %{property: property} do
      subject = Properties.list_properties() |> Enum.at(0)
      assert subject.name == property.name
    end

    test "list_active_properties/0 returns all active properties", %{property: property} do
      insert(:property, %{status: 0, property_type: 1})
      insert(:property, %{status: 1, property_type: 2})
      subject = Properties.list_active_properties()
      assert Enum.count(subject) == 1
      assert Enum.at(subject, 0).name == property.name
    end

    test "get_property!/1 returns the property with given id", %{property: property} do
      assert Properties.get_property!(property.id).name == property.name
    end

    test "create_property/1 with valid data creates a property", %{user: user} do
      valid_attrs = @valid_attrs |> Map.put(:user_id, user.id)
      {:ok, %Property{} = property} = Properties.create_property(valid_attrs)
      assert property.description == "some description"
      assert property.name == "some name"
      assert property.property_type == 42
      assert property.url == "http://google.com"
      assert property.user_id == user.id
    end

    test "create_property/1 with invalid data returns error changeset" do
      {:error, changeset} = Properties.create_property(@invalid_attrs)
      assert changeset.__struct__ == Ecto.Changeset
    end

    test "update_property/2 with valid data updates the property", %{property: property} do
      assert {:ok, property} = Properties.update_property(property, @update_attrs)
      assert Property == property.__struct__
      assert property.description == "some updated description"
      assert property.name == "some updated name"
      assert property.property_type == 43
      assert property.url == "http://aol.com"
    end

    test "update_property/2 with invalid data returns error changeset", %{property: property} do
      assert {:error, %Ecto.Changeset{}} = Properties.update_property(property, @invalid_attrs)
      assert property.name == Properties.get_property!(property.id).name
    end

    test "delete_property/1 deletes the property", %{property: property} do
      assert {:ok, %Property{}} = Properties.delete_property(property)
      assert_raise Ecto.NoResultsError, fn -> Properties.get_property!(property.id) end
    end

    test "change_property/1 returns a property changeset", %{property: property} do
      assert %Ecto.Changeset{} = Properties.change_property(property)
    end
  end
end
