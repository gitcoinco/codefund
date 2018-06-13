defmodule AdService.Math.CPMTest do
  use CodeFund.DataCase
  import CodeFund.Factory

  setup do
    campaign = insert(:campaign)
    user = insert(:user)

    {:ok, %{campaign: campaign, user: user}}
  end

  describe "revenue_amount/1" do
    test "it takes a campaign and returns a revenue_amount", %{campaign: campaign} do
      assert campaign |> AdService.Math.CPM.revenue_amount() == 0.002
    end
  end

  describe "distribution_amount/2" do
    test "it takes a campaign and returns a distribution amount", %{
      campaign: campaign,
      user: user
    } do
      assert campaign |> AdService.Math.CPM.distribution_amount(user) == 0.0012
    end
  end
end
