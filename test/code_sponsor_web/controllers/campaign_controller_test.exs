defmodule CodeSponsorWeb.CampaignControllerTest do
  use CodeSponsorWeb.ConnCase


  test "index/2 should return a list of campaigns", %{conn: conn} do
    user = insert(:user, %{roles: ["admin"]})
    insert_list(25, :campaign, user: user)
    conn = assign conn, :current_user, user
    conn = get conn, campaign_path(conn, :index)
    assert html_response(conn, 200)
  end

  test "new/1 should render a form", %{conn: conn} do
    user = insert(:user, %{roles: ["admin"]})
    conn = assign conn, :current_user, user
    conn = get conn, campaign_path(conn, :new)
    assert html_response(conn, 200) =~ "Code Sponsor | Add Campaign"
  end


  test "show/2 should show a campaign", %{conn: conn} do
    user = insert(:user, %{roles: ["admin"]})
    campaign = insert(:campaign, user: user)
    conn = assign conn, :current_user, user
    conn = get conn, campaign_path(conn, :show, campaign)
    assert html_response(conn, 200) =~ "Code Sponsor | View Campaign"
  end

  test "edit/2 should show a campaign form", %{conn: conn} do
    user = insert(:user, %{roles: ["admin"]})
    campaign = insert(:campaign, user: user)
    conn = assign conn, :current_user, user
    conn = get conn, campaign_path(conn, :edit, campaign)
    assert html_response(conn, 200) =~ "Code Sponsor | Edit Campaign"
  end

  test "delete/2 should delete campaign form", %{conn: conn} do
    user = insert(:user, %{roles: ["admin"]})
    campaign = insert(:campaign, user: user)
    conn = assign conn, :current_user, user
    assert Repo.aggregate(CodeSponsor.Schema.Campaign, :count, :id) == 1
    conn = delete conn, campaign_path(conn, :delete, campaign)
    assert html_response(conn, 302)
    assert Repo.aggregate(CodeSponsor.Schema.Campaign, :count, :id) == 0
  end

  # test "update/2 should show update campaign", %{conn: conn} do
  #   user = insert(:user, %{roles: ["admin"]})
  #   campaign = insert(:campaign, user: user)
  #   conn = assign conn, :current_user, user
  #   saved_campaign = Repo.one(CodeSponsor.Schema.Campaign)
  #   assert saved_campaign.name == "Test Campaign"
  #   params = %{
  #     "id" => campaign.id,
  #     "campaign" => %{
  #       "name" => "namey"
  #     }
  #   }
  #   conn = put conn, campaign_path(conn, :update, campaign), params
  #   updated_campaign = Repo.one(CodeSponsor.Schema.Campaign)
  #   assert updated_campaign.name == "namey"
  # end
end
