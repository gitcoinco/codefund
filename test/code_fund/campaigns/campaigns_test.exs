defmodule CodeFund.CampaignsTest do
  use CodeFund.DataCase
  import CodeFund.Factory

  alias CodeFund.Campaigns

  describe "campaigns" do
    test "get_active_campaign_for_property_with_biggest_bid_amount/1 returns the campaign for a property with largest bid amount" do
      property = insert(:property)

      campaign = insert(:campaign, bid_amount: Decimal.new(10.00))
      insert(:sponsorship, campaign: campaign, property: property)

      insert(:campaign, bid_amount: Decimal.new(1.00))
      insert(:sponsorship, campaign: campaign, property: property)

      assert Campaigns.get_active_campaign_for_property_with_biggest_bid_amount(property).id ==
               campaign.id
    end

    test "get_random_active_campaign_for_property/1 returns a random campaign from all campaigns with highest bid_value for the property" do
      property = insert(:property)
      campaign_1 = insert(:campaign, bid_amount: Decimal.new(25.00))
      campaign_2 = insert(:campaign, bid_amount: Decimal.new(25.00))

      insert(:sponsorship, property: property, campaign: campaign_1)
      insert(:sponsorship, property: property, campaign: campaign_2)

      insert(
        :sponsorship,
        property: property,
        campaign: insert(:campaign, bid_amount: Decimal.new(10.00))
      )

      found_campaign =
        Campaigns.get_random_active_campaign_for_property(property)
        |> CodeFund.Repo.preload(sponsorships: :property)

      assert found_campaign.__struct__ == CodeFund.Schema.Campaign
      assert found_campaign.bid_amount == Decimal.new("25.00")
      assert found_campaign.sponsorships |> List.first() |> Map.get(:property_id) == property.id
    end

    test "get_random_active_campaign_for_property/1 returns nil if the campaign doesn't have an active campaign" do
      property = insert(:property)

      insert(:sponsorship, property: property, campaign: nil)
      refute Campaigns.get_random_active_campaign_for_property(property)
    end
  end
end

#     @valid_attrs %{bid_amount_cents: 42, daily_budget_cents: 42, description: "some description", monthly_budget_cents: 42, name: "some name", redirect_url: "some redirect_url", status: 42}
#     @update_attrs %{bid_amount_cents: 43, daily_budget_cents: 43, description: "some updated description", monthly_budget_cents: 43, name: "some updated name", redirect_url: "some updated redirect_url", status: 43}
#     @invalid_attrs %{bid_amount_cents: nil, daily_budget_cents: nil, description: nil, monthly_budget_cents: nil, name: nil, redirect_url: nil, status: nil}

#     def campaign_fixture(attrs \\ %{}) do
#       {:ok, campaign} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> Campaigns.create_campaign()

#       campaign
#     end

#     test "list_campaigns/0 returns all campaigns" do
#       campaign = campaign_fixture()
#       assert Campaigns.list_campaigns() == [campaign]
#     end

#     test "get_campaign!/1 returns the campaign with given id" do
#       campaign = campaign_fixture()
#       assert Campaigns.get_campaign!(campaign.id) == campaign
#     end

#     test "create_campaign/1 with valid data creates a campaign" do
#       assert {:ok, %Campaign{} = campaign} = Campaigns.create_campaign(@valid_attrs)
#       assert campaign.bid_amount_cents == 42
#       assert campaign.daily_budget_cents == 42
#       assert campaign.description == "some description"
#       assert campaign.monthly_budget_cents == 42
#       assert campaign.name == "some name"
#       assert campaign.redirect_url == "some redirect_url"
#       assert campaign.status == 42
#     end

#     test "create_campaign/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Campaigns.create_campaign(@invalid_attrs)
#     end

#     test "update_campaign/2 with valid data updates the campaign" do
#       campaign = campaign_fixture()
#       assert {:ok, campaign} = Campaigns.update_campaign(campaign, @update_attrs)
#       assert %Campaign{} = campaign
#       assert campaign.bid_amount_cents == 43
#       assert campaign.daily_budget_cents == 43
#       assert campaign.description == "some updated description"
#       assert campaign.monthly_budget_cents == 43
#       assert campaign.name == "some updated name"
#       assert campaign.redirect_url == "some updated redirect_url"
#       assert campaign.status == 43
#     end

#     test "update_campaign/2 with invalid data returns error changeset" do
#       campaign = campaign_fixture()
#       assert {:error, %Ecto.Changeset{}} = Campaigns.update_campaign(campaign, @invalid_attrs)
#       assert campaign == Campaigns.get_campaign!(campaign.id)
#     end

#     test "delete_campaign/1 deletes the campaign" do
#       campaign = campaign_fixture()
#       assert {:ok, %Campaign{}} = Campaigns.delete_campaign(campaign)
#       assert_raise Ecto.NoResultsError, fn -> Campaigns.get_campaign!(campaign.id) end
#     end

#     test "change_campaign/1 returns a campaign changeset" do
#       campaign = campaign_fixture()
#       assert %Ecto.Changeset{} = Campaigns.change_campaign(campaign)
#     end
#   end
# end
