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
end
