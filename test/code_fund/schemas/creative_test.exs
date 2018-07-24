defmodule CodeFund.Schema.CreativeTest do
  use CodeFund.DataCase
  alias CodeFund.Schema.Creative
  import CodeFund.Factory

  describe "creatives" do
    setup do
      valid_attrs = build(:creative, user_id: insert(:user).id) |> Map.from_struct()
      {:ok, %{valid_attrs: valid_attrs}}
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      assert Creative.changeset(%Creative{}, valid_attrs).valid?
    end

    test "changeset with missing required attributes", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.required_attribute_test(
        Creative,
        Creative.required(),
        valid_attrs |> Map.delete(:large_image)
      )
    end

    test "changeset with invalid image_url", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.url_validation_test(Creative, :image_url, valid_attrs)
    end

    test "it casts an upload struct to keys for the database" do
      valid_attrs =
        build(
          :creative,
          user_id: insert(:user).id,
          large_image_object: nil,
          large_image_bucket: nil
        )
        |> Map.from_struct()

      changeset = Creative.changeset(%Creative{}, valid_attrs)

      assert changeset.changes.large_image_bucket == "stub"
      assert changeset.changes.large_image_object =~ "_mock.jpg"
    end
  end
end
