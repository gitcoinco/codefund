defmodule CodeSponsorWeb.CampaignControllerTest do
  use CodeSponsorWeb.ConnCase

  alias CodeSponsor.Campaigns

  @create_attrs %{bid_amount_cents: 42, daily_budget_cents: 42, description: "some description", monthly_budget_cents: 42, name: "some name", redirect_url: "some redirect_url", status: 42}
  @update_attrs %{bid_amount_cents: 43, daily_budget_cents: 43, description: "some updated description", monthly_budget_cents: 43, name: "some updated name", redirect_url: "some updated redirect_url", status: 43}
  @invalid_attrs %{bid_amount_cents: nil, daily_budget_cents: nil, description: nil, monthly_budget_cents: nil, name: nil, redirect_url: nil, status: nil}

  def fixture(:campaign) do
    {:ok, campaign} = Campaigns.create_campaign(@create_attrs)
    campaign
  end

  describe "index" do
    test "lists all campaigns", %{conn: conn} do
      conn = get conn, campaign_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Campaigns"
    end
  end

  describe "new campaign" do
    test "renders form", %{conn: conn} do
      conn = get conn, campaign_path(conn, :new)
      assert html_response(conn, 200) =~ "New Campaign"
    end
  end

  describe "create campaign" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, campaign_path(conn, :create), campaign: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == campaign_path(conn, :show, id)

      conn = get conn, campaign_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Campaign"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, campaign_path(conn, :create), campaign: @invalid_attrs
      assert html_response(conn, 200) =~ "New Campaign"
    end
  end

  describe "edit campaign" do
    setup [:create_campaign]

    test "renders form for editing chosen campaign", %{conn: conn, campaign: campaign} do
      conn = get conn, campaign_path(conn, :edit, campaign)
      assert html_response(conn, 200) =~ "Edit Campaign"
    end
  end

  describe "update campaign" do
    setup [:create_campaign]

    test "redirects when data is valid", %{conn: conn, campaign: campaign} do
      conn = put conn, campaign_path(conn, :update, campaign), campaign: @update_attrs
      assert redirected_to(conn) == campaign_path(conn, :show, campaign)

      conn = get conn, campaign_path(conn, :show, campaign)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, campaign: campaign} do
      conn = put conn, campaign_path(conn, :update, campaign), campaign: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Campaign"
    end
  end

  describe "delete campaign" do
    setup [:create_campaign]

    test "deletes chosen campaign", %{conn: conn, campaign: campaign} do
      conn = delete conn, campaign_path(conn, :delete, campaign)
      assert redirected_to(conn) == campaign_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, campaign_path(conn, :show, campaign)
      end
    end
  end

  defp create_campaign(_) do
    campaign = fixture(:campaign)
    {:ok, campaign: campaign}
  end
end
