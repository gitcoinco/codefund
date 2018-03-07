# defmodule CodeSponsor.ClicksTest do
#   use CodeSponsor.DataCase

#   alias CodeSponsor.Clicks

#   describe "clicks" do
#     alias CodeSponsor.Clicks.Click

#     @valid_attrs %{browser: "some browser", city: "some city", country: "some country", device_type: "some device_type", ip: "some ip", landing_page: "some landing_page", latitude: "120.5", longitude: "120.5", os: "some os", postal_code: "some postal_code", referrer: "some referrer", referring_domain: "some referring_domain", region: "some region", screen_height: 42, screen_width: 42, search_keyword: "some search_keyword", user_agent: "some user_agent", utm_campaign: "some utm_campaign", utm_content: "some utm_content", utm_medium: "some utm_medium", utm_source: "some utm_source", utm_term: "some utm_term"}
#     @update_attrs %{browser: "some updated browser", city: "some updated city", country: "some updated country", device_type: "some updated device_type", ip: "some updated ip", landing_page: "some updated landing_page", latitude: "456.7", longitude: "456.7", os: "some updated os", postal_code: "some updated postal_code", referrer: "some updated referrer", referring_domain: "some updated referring_domain", region: "some updated region", screen_height: 43, screen_width: 43, search_keyword: "some updated search_keyword", user_agent: "some updated user_agent", utm_campaign: "some updated utm_campaign", utm_content: "some updated utm_content", utm_medium: "some updated utm_medium", utm_source: "some updated utm_source", utm_term: "some updated utm_term"}
#     @invalid_attrs %{browser: nil, city: nil, country: nil, device_type: nil, ip: nil, landing_page: nil, latitude: nil, longitude: nil, os: nil, postal_code: nil, referrer: nil, referring_domain: nil, region: nil, screen_height: nil, screen_width: nil, search_keyword: nil, user_agent: nil, utm_campaign: nil, utm_content: nil, utm_medium: nil, utm_source: nil, utm_term: nil}

#     def click_fixture(attrs \\ %{}) do
#       {:ok, click} =
#         attrs
#         |> Enum.into(@valid_attrs)
#         |> Clicks.create_click()

#       click
#     end

#     test "list_clicks/0 returns all clicks" do
#       click = click_fixture()
#       assert Clicks.list_clicks() == [click]
#     end

#     test "get_click!/1 returns the click with given id" do
#       click = click_fixture()
#       assert Clicks.get_click!(click.id) == click
#     end

#     test "create_click/1 with valid data creates a click" do
#       assert {:ok, %Click{} = click} = Clicks.create_click(@valid_attrs)
#       assert click.browser == "some browser"
#       assert click.city == "some city"
#       assert click.country == "some country"
#       assert click.device_type == "some device_type"
#       assert click.ip == "some ip"
#       assert click.landing_page == "some landing_page"
#       assert click.latitude == Decimal.new("120.5")
#       assert click.longitude == Decimal.new("120.5")
#       assert click.os == "some os"
#       assert click.postal_code == "some postal_code"
#       assert click.referrer == "some referrer"
#       assert click.referring_domain == "some referring_domain"
#       assert click.region == "some region"
#       assert click.screen_height == 42
#       assert click.screen_width == 42
#       assert click.search_keyword == "some search_keyword"
#       assert click.user_agent == "some user_agent"
#       assert click.utm_campaign == "some utm_campaign"
#       assert click.utm_content == "some utm_content"
#       assert click.utm_medium == "some utm_medium"
#       assert click.utm_source == "some utm_source"
#       assert click.utm_term == "some utm_term"
#     end

#     test "create_click/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Clicks.create_click(@invalid_attrs)
#     end

#     test "update_click/2 with valid data updates the click" do
#       click = click_fixture()
#       assert {:ok, click} = Clicks.update_click(click, @update_attrs)
#       assert %Click{} = click
#       assert click.browser == "some updated browser"
#       assert click.city == "some updated city"
#       assert click.country == "some updated country"
#       assert click.device_type == "some updated device_type"
#       assert click.ip == "some updated ip"
#       assert click.landing_page == "some updated landing_page"
#       assert click.latitude == Decimal.new("456.7")
#       assert click.longitude == Decimal.new("456.7")
#       assert click.os == "some updated os"
#       assert click.postal_code == "some updated postal_code"
#       assert click.referrer == "some updated referrer"
#       assert click.referring_domain == "some updated referring_domain"
#       assert click.region == "some updated region"
#       assert click.screen_height == 43
#       assert click.screen_width == 43
#       assert click.search_keyword == "some updated search_keyword"
#       assert click.user_agent == "some updated user_agent"
#       assert click.utm_campaign == "some updated utm_campaign"
#       assert click.utm_content == "some updated utm_content"
#       assert click.utm_medium == "some updated utm_medium"
#       assert click.utm_source == "some updated utm_source"
#       assert click.utm_term == "some updated utm_term"
#     end

#     test "update_click/2 with invalid data returns error changeset" do
#       click = click_fixture()
#       assert {:error, %Ecto.Changeset{}} = Clicks.update_click(click, @invalid_attrs)
#       assert click == Clicks.get_click!(click.id)
#     end

#     test "delete_click/1 deletes the click" do
#       click = click_fixture()
#       assert {:ok, %Click{}} = Clicks.delete_click(click)
#       assert_raise Ecto.NoResultsError, fn -> Clicks.get_click!(click.id) end
#     end

#     test "change_click/1 returns a click changeset" do
#       click = click_fixture()
#       assert %Ecto.Changeset{} = Clicks.change_click(click)
#     end
#   end
# end
