defmodule CodeSponsor.CampaignsTest do
  use CodeSponsor.DataCase

  alias CodeSponsor.Campaigns

  describe "campaigns" do
    alias CodeSponsor.Campaigns.Campaign

    @valid_attrs %{bid_amount: 42, budget_daily_amount: 42, description: "some description", budget_monthly_amount: 42, name: "some name", redirect_url: "some redirect_url", status: 42}
    @update_attrs %{bid_amount: Decimal.new(43), budget_daily_amount: Decimal.new(43), description: "some updated description", budget_monthly_amount: Decimal.new(43), name: "some updated name", redirect_url: "some updated redirect_url", status: 43}
    @invalid_attrs %{bid_amount: nil, daily_budget: nil, description: nil, monthly_budget_cents: nil, name: nil, redirect_url: nil, status: nil}

    test "get_campaign!/1 returns the campaign with given id" do
      user = insert(:user)
      campaign = insert(:campaign, user: user)
      inserted_campaign = Campaigns.get_campaign!(campaign.id)

      assert campaign.id == inserted_campaign.id
    end

    test "create_campaign/1 with valid data creates a campaign" do
      user = insert(:user)
      assert {:ok, %Campaign{} = campaign} = Campaigns.create_campaign(Map.put(@valid_attrs, :user_id, user.id))
      assert campaign.bid_amount == Decimal.new(42)
      assert campaign.budget_daily_amount == Decimal.new(42)
      assert campaign.description == "some description"
      assert campaign.budget_monthly_amount == Decimal.new(42)
      assert campaign.name == "some name"
      assert campaign.redirect_url == "some redirect_url"
      assert campaign.status == 42
    end

    test "create_campaign/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Campaigns.create_campaign(@invalid_attrs)
    end

    test "update_campaign/2 with valid data updates the campaign" do
      user = insert(:user)
      campaign = insert(:campaign, user: user)
      assert {:ok, campaign} = Campaigns.update_campaign(campaign, @update_attrs)
      assert %Campaign{} = campaign
      assert campaign.bid_amount == Decimal.new(43)
      assert campaign.budget_daily_amount == Decimal.new(43)
      assert campaign.description == "some updated description"
      assert campaign.budget_monthly_amount == Decimal.new(43)
      assert campaign.name == "some updated name"
      assert campaign.redirect_url == "some updated redirect_url"
      assert campaign.status == 43
    end

    test "update_campaign/2 with invalid data returns error changeset" do
      user = insert(:user)
      campaign = insert(:campaign, user: user)
      assert {:error, %Ecto.Changeset{}} = Campaigns.update_campaign(campaign, @invalid_attrs)
    end

    test "delete_campaign/1 deletes the campaign" do
      user = insert(:user)
      campaign = insert(:campaign, user: user)
      assert {:ok, %Campaign{}} = Campaigns.delete_campaign(campaign)
      assert_raise Ecto.NoResultsError, fn -> Campaigns.get_campaign!(campaign.id) end
    end

    test "change_campaign/1 returns a campaign changeset" do
      user = insert(:user)
      campaign = insert(:campaign, user: user)
      assert %Ecto.Changeset{} = Campaigns.change_campaign(campaign)
    end
  end
end
