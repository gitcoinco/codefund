defmodule CodeFund.Schema.PropertyTest do
  use CodeFund.DataCase
  alias CodeFund.Schema.Property
  import CodeFund.Factory

  describe "properties" do
    setup do
      valid_attrs = build(:property, user_id: insert(:user).id) |> Map.from_struct()
      {:ok, %{valid_attrs: valid_attrs}}
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      assert Property.changeset(%Property{}, valid_attrs).valid?
    end

    test "changeset with missing required attributes", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.required_attribute_test(Property, Property.required(), valid_attrs)
    end

    test "changeset with failing valid length on array fields", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.length_validation_test(
        Property,
        [:programming_languages],
        valid_attrs
      )
    end

    test "changeset with invalid screenshot_url & url", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.url_validation_test(Property, :url, valid_attrs)
      SharedExample.ModelTests.url_validation_test(Property, :screenshot_url, valid_attrs)
    end
  end
end
