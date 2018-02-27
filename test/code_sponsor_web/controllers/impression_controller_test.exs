defmodule CodeSponsorWeb.ImpressionControllerTest do
  use CodeSponsorWeb.ConnCase

  alias CodeSponsor.Impressions

  @create_attrs %{browser: "some browser", city: "some city", country: "some country", device_type: "some device_type", ip: "some ip", latitude: "120.5", longitude: "120.5", os: "some os", postal_code: "some postal_code", region: "some region", screen_height: 42, screen_width: 42, user_agent: "some user_agent", utm_campaign: "some utm_campaign", utm_content: "some utm_content", utm_medium: "some utm_medium", utm_source: "some utm_source", utm_term: "some utm_term"}
  @update_attrs %{browser: "some updated browser", city: "some updated city", country: "some updated country", device_type: "some updated device_type", ip: "some updated ip", latitude: "456.7", longitude: "456.7", os: "some updated os", postal_code: "some updated postal_code", region: "some updated region", screen_height: 43, screen_width: 43, user_agent: "some updated user_agent", utm_campaign: "some updated utm_campaign", utm_content: "some updated utm_content", utm_medium: "some updated utm_medium", utm_source: "some updated utm_source", utm_term: "some updated utm_term"}
  @invalid_attrs %{browser: nil, city: nil, country: nil, device_type: nil, ip: nil, latitude: nil, longitude: nil, os: nil, postal_code: nil, region: nil, screen_height: nil, screen_width: nil, user_agent: nil, utm_campaign: nil, utm_content: nil, utm_medium: nil, utm_source: nil, utm_term: nil}

  def fixture(:impression) do
    {:ok, impression} = Impressions.create_impression(@create_attrs)
    impression
  end

  describe "index" do
    test "lists all impressions", %{conn: conn} do
      conn = get conn, impression_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Impressions"
    end
  end

  describe "new impression" do
    test "renders form", %{conn: conn} do
      conn = get conn, impression_path(conn, :new)
      assert html_response(conn, 200) =~ "New Impression"
    end
  end

  describe "create impression" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, impression_path(conn, :create), impression: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == impression_path(conn, :show, id)

      conn = get conn, impression_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Impression"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, impression_path(conn, :create), impression: @invalid_attrs
      assert html_response(conn, 200) =~ "New Impression"
    end
  end

  describe "edit impression" do
    setup [:create_impression]

    test "renders form for editing chosen impression", %{conn: conn, impression: impression} do
      conn = get conn, impression_path(conn, :edit, impression)
      assert html_response(conn, 200) =~ "Edit Impression"
    end
  end

  describe "update impression" do
    setup [:create_impression]

    test "redirects when data is valid", %{conn: conn, impression: impression} do
      conn = put conn, impression_path(conn, :update, impression), impression: @update_attrs
      assert redirected_to(conn) == impression_path(conn, :show, impression)

      conn = get conn, impression_path(conn, :show, impression)
      assert html_response(conn, 200) =~ "some updated browser"
    end

    test "renders errors when data is invalid", %{conn: conn, impression: impression} do
      conn = put conn, impression_path(conn, :update, impression), impression: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Impression"
    end
  end

  describe "delete impression" do
    setup [:create_impression]

    test "deletes chosen impression", %{conn: conn, impression: impression} do
      conn = delete conn, impression_path(conn, :delete, impression)
      assert redirected_to(conn) == impression_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, impression_path(conn, :show, impression)
      end
    end
  end

  defp create_impression(_) do
    impression = fixture(:impression)
    {:ok, impression: impression}
  end
end
