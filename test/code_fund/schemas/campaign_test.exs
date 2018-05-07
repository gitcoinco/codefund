defmodule CodeFund.Schema.CampaignTest do
  use CodeFund.DataCase
  alias CodeFund.Schema.Campaign
  import CodeFund.Factory

  describe "campaigns" do
    setup do
      valid_attrs =
        build(:campaign, user_id: insert(:user).id, audience_id: insert(:audience).id)
        |> Map.from_struct()

      {:ok, %{valid_attrs: valid_attrs}}
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      assert Campaign.changeset(%Campaign{}, valid_attrs).valid?
    end

    test "changeset with missing required attributes", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.required_attribute_test(Campaign, Campaign.required(), valid_attrs)
    end

    test "changeset with invalid redirect_url or fraud_check_url", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.url_validation_test(Campaign, :redirect_url, valid_attrs)
      SharedExample.ModelTests.url_validation_test(Campaign, :fraud_check_url, valid_attrs)
    end
  end
end
