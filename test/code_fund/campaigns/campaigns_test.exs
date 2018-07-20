defmodule CodeFund.CampaignsTest do
  use CodeFund.DataCase
  import CodeFund.Factory

  describe("#archive/1") do
    test "it archives a campaign" do
      date_stub = Timex.now() |> DateTime.to_naive()
      campaign = insert(:campaign, status: 2, start_date: date_stub, end_date: date_stub)

      {:ok, campaign} = CodeFund.Campaigns.archive(campaign)

      assert campaign.status == 3
    end

    test "it returns an error if the campaign is already archived" do
      campaign = insert(:campaign, status: 3)

      assert CodeFund.Campaigns.archive(campaign) == {:error, :already_archived}
    end
  end

  describe("list_of_ids_for_companies/1") do
    test "returns a list of campaign ids for the companies passed in" do
      user_1 = insert(:user, company: "Foobar, Inc")
      user_2 = insert(:user, company: "BarFoo")
      user_3 = insert(:user, company: nil)
      user_4 = insert(:user, company: "Acme")
      user_5 = insert(:user, company: "Foobar, Inc")

      campaign_1 = insert(:campaign, user: user_1)
      campaign_2 = insert(:campaign, user: user_1)
      _campaign_3 = insert(:campaign, user: user_2)
      _campaign_4 = insert(:campaign, user: user_3)
      campaign_5 = insert(:campaign, user: user_4)
      campaign_6 = insert(:campaign, user: user_5)

      result =
        CodeFund.Campaigns.list_of_ids_for_companies(["Foobar, Inc", "Acme"]) |> Enum.sort()

      list_of_ids =
        [
          campaign_1.id,
          campaign_2.id,
          campaign_5.id,
          campaign_6.id
        ]
        |> Enum.sort()

      assert result == list_of_ids
    end
  end
end
