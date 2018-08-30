defmodule CodeFund.Schema.AssetTest do
  use CodeFund.DataCase
  alias CodeFund.Schema.Asset
  import CodeFund.Factory

  describe "assets" do
    setup do
      valid_attrs = build(:asset) |> Map.from_struct()
      {:ok, %{valid_attrs: valid_attrs}}
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      assert Asset.changeset(%Asset{}, valid_attrs).valid?
    end

    test "changeset with missing required attributes", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.required_attribute_test(
        Asset,
        Asset.required(),
        valid_attrs |> Map.delete(:image)
      )
    end

    test "it casts an upload struct to keys for the database" do
      valid_attrs =
        build(
          :asset,
          user_id: insert(:user).id,
          image_object: nil,
          image_bucket: nil
        )
        |> Map.from_struct()

      changeset = Asset.changeset(%Asset{}, valid_attrs)

      assert changeset.changes.image_bucket == "stub"
      assert changeset.changes.image_object =~ "_mock.jpg"
    end
  end
end
