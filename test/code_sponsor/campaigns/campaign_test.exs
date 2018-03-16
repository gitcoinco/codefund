defmodule CodeSponsor.Campaigns.CampaignTest do
  use CodeSponsor.DataCase

  alias CodeSponsor.Campaigns.Campaign

  @valid_attrs %{user_id: "123", name: "Zacck", redirect_url: "https://lol.co", status: 1, bid_amount: 3.4, budget_daily_amount: 5.5,
  budget_monthly_amount: 2.2,
   budget_total_amount: 1.1}

  @invalid_attrs %{}
  describe "campaign changeset" do
    test "valid when attributes are ok" do
      changeset = Campaign.changeset(%Campaign{}, @valid_attrs)
      assert changeset.valid?
    end

    test "invalid when attributes are not" do
      changeset = Campaign.changeset(%Campaign{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

end
