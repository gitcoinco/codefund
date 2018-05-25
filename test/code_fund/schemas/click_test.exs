defmodule CodeFund.Schema.ClickTest do
  use CodeFund.DataCase
  alias CodeFund.Schema.Click
  import CodeFund.Factory

  describe "clicks" do
    setup do
      valid_attrs = build(:click, property_id: insert(:property).id) |> Map.from_struct()
      {:ok, %{valid_attrs: valid_attrs}}
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      assert Click.changeset(%Click{}, valid_attrs).valid?
    end

    test "changeset with missing required attributes", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.required_attribute_test(Click, Click.required(), valid_attrs)
    end

    test "changeset with invalid redirected_to_url", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.url_validation_test(Click, :redirected_to_url, valid_attrs)
    end
  end
end
