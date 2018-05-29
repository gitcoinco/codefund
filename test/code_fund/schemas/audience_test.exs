defmodule CodeFund.Schema.AudienceTest do
  use CodeFund.DataCase
  alias CodeFund.Schema.Audience
  import CodeFund.Factory

  describe "audiences" do
    setup do
      valid_attrs = build(:audience, user_id: insert(:user).id) |> Map.from_struct()
      {:ok, %{valid_attrs: valid_attrs}}
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      assert Audience.changeset(%Audience{}, valid_attrs).valid?
    end

    test "changeset with missing required attributes", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.required_attribute_test(Audience, Audience.required(), valid_attrs)
    end
  end
end
