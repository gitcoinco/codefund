defmodule CodeFund.Schema.PropertyTest do
  use CodeFund.DataCase
  alias CodeFund.Schema.Property
  import CodeFund.Factory

  describe "properties" do
    setup do
      valid_attrs =
        build(:property, name: "Some Thing", user_id: insert(:user).id) |> Map.from_struct()

      {:ok, %{valid_attrs: valid_attrs}}
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      assert Property.changeset(%Property{}, valid_attrs).valid?
    end

    test "changeset with non_unique slug", %{valid_attrs: valid_attrs} do
      {:ok, property} = CodeFund.Properties.create_property(valid_attrs |> Map.delete(:slug))
      assert property.slug == "some_thing"
      changeset = Property.changeset(%Property{}, valid_attrs)
      assert changeset.changes.slug == "some_thing_2"
    end

    test "changeset with missing required attributes", %{valid_attrs: valid_attrs} do
      required_fields = Property.required() |> Enum.reject(fn attr -> attr == :slug end)
      SharedExample.ModelTests.required_attribute_test(Property, required_fields, valid_attrs)
    end

    test "changeset with invalid screenshot_url & url", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.url_validation_test(Property, :url, valid_attrs)
      SharedExample.ModelTests.url_validation_test(Property, :screenshot_url, valid_attrs)
    end

    test "if nothing is passed in the params for a list column, it will set it to empty list", %{
      valid_attrs: valid_attrs
    } do
      assert Property.changeset(%Property{}, %{}) |> get_field(:programming_languages) == []
      assert Property.changeset(%Property{}, %{}) |> get_field(:topic_categories) == []

      {:ok, property} = CodeFund.Properties.create_property(valid_attrs)

      assert Property.changeset(property, %{topic_categories: ["Frontend Frameworks & Tools"]})
             |> get_field(:programming_languages) == []

      assert Property.changeset(property, %{programming_languages: ["Ruby"]})
             |> get_field(:topic_categories) == []
    end
  end
end
