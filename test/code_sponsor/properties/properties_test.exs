 defmodule CodeSponsor.PropertiesTest do
   use CodeSponsor.DataCase

   alias CodeSponsor.{Properties, Coherence.User}

   describe "properties" do
    alias CodeSponsor.Schema.Property

     @valid_attrs %{"name" => "some name", "property_type" =>  42, "url" => "some url"}
     @update_attrs %{"name" => "some updated name", "property_type" =>  43, "url" => "some updated url"}
     @invalid_attrs %{description: nil, name: nil, property_type: nil, url: nil}


     test "list_properties/0 returns all properties" do
       property = insert(:property)
       [first_prop | _] =  Properties.list_properties()
       assert first_prop.id == property.id
     end

     test "paginate_properties/1 paginates properties" do
       user = insert(:user)
       property = insert_list(25, :property, user: user)
       {:ok, %{properties: properties}} = Properties.paginate_properties(user, %{})
       assert Enum.count(properties) == 15
     end

     test "get_property!/1 returns the property with given id" do
       property = insert(:property)
       saved_prop = Properties.get_property!(property.id)
       assert saved_prop.id == property.id
    end

     test "create_property/1 with valid data creates a property" do
       user = insert(:user)
       {:ok, property} = Properties.create_property(Map.put(@valid_attrs, "user_id", user.id))
       assert property.name == "some name"
       assert property.property_type == 42
       assert property.url == "some url"
     end

    test "create_property/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Properties.create_property(@invalid_attrs)
    end

    test "update_property/2 with valid data updates the property" do
      property = insert(:property)
      assert {:ok, property} = Properties.update_property(property, @update_attrs)
      assert %Property{} = property
      assert property.name == "some updated name"
      assert property.property_type == 43
      assert property.url == "some updated url"
    end

    test "update_property/2 with invalid data returns error changeset" do
      property = insert(:property)
      assert {:error, %Ecto.Changeset{}} = Properties.update_property(property, @invalid_attrs)
      saved_property = Properties.get_property!(property.id)
    end

    test "delete_property/1 deletes the property" do
      property = insert(:property)
      assert {:ok, %Property{}} = Properties.delete_property(property)
      assert_raise Ecto.NoResultsError, fn -> Properties.get_property!(property.id) end
    end

    test "change_property/1 returns a property changeset" do
      property = insert(:property)
      assert %Ecto.Changeset{} = Properties.change_property(property)
    end

    test "change_property/2 returns a property changeset" do
      property = insert(:property)
      user = insert(:user)
      assert %Ecto.Changeset{} = Properties.change_property(property, %{user: Map.from_struct(user)})
    end
   end
 end
