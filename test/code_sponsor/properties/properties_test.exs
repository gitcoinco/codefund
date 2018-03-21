# defmodule CodeSponsor.PropertiesTest do
#   use CodeSponsor.DataCase

#   alias CodeSponsor.Properties

#   describe "properties" do
#     alias CodeSponsor.Schema.Property

#     @valid_attrs %{description: "some description", name: "some name", property_type: 42, url: "some url"}
#     @update_attrs %{description: "some updated description", name: "some updated name", property_type: 43, url: "some updated url"}
#     @invalid_attrs %{description: nil, name: nil, property_type: nil, url: nil}

#     def property_fixture(attrs \\ %{}) do
#       {:ok, property} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> Properties.create_property()

#       property
#     end

#     test "list_properties/0 returns all properties" do
#       property = property_fixture()
#       assert Properties.list_properties() == [property]
#     end

#     test "get_property!/1 returns the property with given id" do
#       property = property_fixture()
#       assert Properties.get_property!(property.id) == property
#     end

#     test "create_property/1 with valid data creates a property" do
#       assert {:ok, %Property{} = property} = Properties.create_property(@valid_attrs)
#       assert property.description == "some description"
#       assert property.name == "some name"
#       assert property.property_type == 42
#       assert property.url == "some url"
#     end

#     test "create_property/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Properties.create_property(@invalid_attrs)
#     end

#     test "update_property/2 with valid data updates the property" do
#       property = property_fixture()
#       assert {:ok, property} = Properties.update_property(property, @update_attrs)
#       assert %Property{} = property
#       assert property.description == "some updated description"
#       assert property.name == "some updated name"
#       assert property.property_type == 43
#       assert property.url == "some updated url"
#     end

#     test "update_property/2 with invalid data returns error changeset" do
#       property = property_fixture()
#       assert {:error, %Ecto.Changeset{}} = Properties.update_property(property, @invalid_attrs)
#       assert property == Properties.get_property!(property.id)
#     end

#     test "delete_property/1 deletes the property" do
#       property = property_fixture()
#       assert {:ok, %Property{}} = Properties.delete_property(property)
#       assert_raise Ecto.NoResultsError, fn -> Properties.get_property!(property.id) end
#     end

#     test "change_property/1 returns a property changeset" do
#       property = property_fixture()
#       assert %Ecto.Changeset{} = Properties.change_property(property)
#     end
#   end
# end
