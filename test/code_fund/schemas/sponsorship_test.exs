defmodule CodeFund.Schema.SponsorshipTest do
  use CodeFund.DataCase
  alias CodeFund.Schema.Sponsorship
  import CodeFund.Factory

  describe "sponsorships" do
    setup do
      valid_attrs = build(:sponsorship) |> Map.from_struct()
      {:ok, %{valid_attrs: valid_attrs}}
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      assert Sponsorship.changeset(%Sponsorship{}, valid_attrs).valid?
    end

    test "changeset with missing required attributes", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.required_attribute_test(
        Sponsorship,
        Sponsorship.required(),
        valid_attrs
      )
    end

    test "changeset with invalid redirect_url", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.url_validation_test(Sponsorship, :redirect_url, valid_attrs)
    end
  end
end
