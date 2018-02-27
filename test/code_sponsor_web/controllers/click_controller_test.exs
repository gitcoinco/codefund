defmodule CodeSponsorWeb.ClickControllerTest do
  use CodeSponsorWeb.ConnCase

  alias CodeSponsor.Clicks

  @create_attrs %{browser: "some browser", city: "some city", country: "some country", device_type: "some device_type", ip: "some ip", landing_page: "some landing_page", latitude: "120.5", longitude: "120.5", os: "some os", postal_code: "some postal_code", referrer: "some referrer", referring_domain: "some referring_domain", region: "some region", screen_height: 42, screen_width: 42, search_keyword: "some search_keyword", user_agent: "some user_agent", utm_campaign: "some utm_campaign", utm_content: "some utm_content", utm_medium: "some utm_medium", utm_source: "some utm_source", utm_term: "some utm_term"}
  @update_attrs %{browser: "some updated browser", city: "some updated city", country: "some updated country", device_type: "some updated device_type", ip: "some updated ip", landing_page: "some updated landing_page", latitude: "456.7", longitude: "456.7", os: "some updated os", postal_code: "some updated postal_code", referrer: "some updated referrer", referring_domain: "some updated referring_domain", region: "some updated region", screen_height: 43, screen_width: 43, search_keyword: "some updated search_keyword", user_agent: "some updated user_agent", utm_campaign: "some updated utm_campaign", utm_content: "some updated utm_content", utm_medium: "some updated utm_medium", utm_source: "some updated utm_source", utm_term: "some updated utm_term"}
  @invalid_attrs %{browser: nil, city: nil, country: nil, device_type: nil, ip: nil, landing_page: nil, latitude: nil, longitude: nil, os: nil, postal_code: nil, referrer: nil, referring_domain: nil, region: nil, screen_height: nil, screen_width: nil, search_keyword: nil, user_agent: nil, utm_campaign: nil, utm_content: nil, utm_medium: nil, utm_source: nil, utm_term: nil}

  def fixture(:click) do
    {:ok, click} = Clicks.create_click(@create_attrs)
    click
  end

  describe "index" do
    test "lists all clicks", %{conn: conn} do
      conn = get conn, click_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Clicks"
    end
  end

  describe "new click" do
    test "renders form", %{conn: conn} do
      conn = get conn, click_path(conn, :new)
      assert html_response(conn, 200) =~ "New Click"
    end
  end

  describe "create click" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, click_path(conn, :create), click: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == click_path(conn, :show, id)

      conn = get conn, click_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Click"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, click_path(conn, :create), click: @invalid_attrs
      assert html_response(conn, 200) =~ "New Click"
    end
  end

  describe "edit click" do
    setup [:create_click]

    test "renders form for editing chosen click", %{conn: conn, click: click} do
      conn = get conn, click_path(conn, :edit, click)
      assert html_response(conn, 200) =~ "Edit Click"
    end
  end

  describe "update click" do
    setup [:create_click]

    test "redirects when data is valid", %{conn: conn, click: click} do
      conn = put conn, click_path(conn, :update, click), click: @update_attrs
      assert redirected_to(conn) == click_path(conn, :show, click)

      conn = get conn, click_path(conn, :show, click)
      assert html_response(conn, 200) =~ "some updated browser"
    end

    test "renders errors when data is invalid", %{conn: conn, click: click} do
      conn = put conn, click_path(conn, :update, click), click: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Click"
    end
  end

  describe "delete click" do
    setup [:create_click]

    test "deletes chosen click", %{conn: conn, click: click} do
      conn = delete conn, click_path(conn, :delete, click)
      assert redirected_to(conn) == click_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, click_path(conn, :show, click)
      end
    end
  end

  defp create_click(_) do
    click = fixture(:click)
    {:ok, click: click}
  end
end
