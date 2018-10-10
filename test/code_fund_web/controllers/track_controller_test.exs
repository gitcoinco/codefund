defmodule CodeFundWeb.TrackControllerTest do
  use CodeFundWeb.ConnCase

  @user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"

  setup do
    transparent_png =
      <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8,
        4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 156, 99, 250, 207, 0, 0, 2,
        7, 1, 2, 154, 28, 49, 113, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130>>

    conn = build_conn() |> Map.put(:remote_ip, {67, 139, 178, 66})

    {:ok, %{transparent_png: transparent_png, conn: conn}}
  end

  describe "pixel/2" do
    test "Renders a transparent png and updates the impression with details about the browser", %{
      conn: conn,
      transparent_png: transparent_png
    } do
      impression = insert(:impression)

      conn =
        conn
        |> put_req_header("user-agent", @user_agent)
        |> get("/p/#{impression.id}/pixel.png")

      content_type = conn |> get_resp_header("content-type") |> Enum.at(0)

      assert content_type == "image/png; charset=utf-8"
      assert conn.resp_body == transparent_png

      impression = CodeFund.Impressions.get_impression!(impression.id)
      assert impression.ip == "67.139.178.66"

      assert impression.user_agent ==
               "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"

      assert impression.os == "mac"
      assert impression.device_type == "desktop"

      assert impression.country == "US"
      assert impression.city == "Portland"
      assert impression.region == "Oregon"
      assert impression.latitude == Decimal.new(45.5207)
      assert impression.longitude == Decimal.new(-122.6888)
      assert impression.postal_code == "97205"
    end
  end

  describe "click/2" do
    test "updates the impression with redirect information and redirects the visitor", %{
      conn: conn
    } do
      user = insert(:user, revenue_rate: Decimal.new(0.3))
      property = insert(:property, user: user)

      impression =
        insert(
          :impression,
          property: property,
          campaign:
            insert(
              :campaign,
              ecpm: Decimal.new(2.00),
              redirect_url: "http://another.url"
            )
        )

      conn = conn |> put_req_header("user-agent", @user_agent)
      conn = get(conn, track_path(conn, :click, impression))

      impression = CodeFund.Impressions.get_impression!(impression.id)

      assert impression.redirected_to_url == "http://another.url?utm_term=#{property.slug}"
      refute impression.redirected_at |> is_nil

      assert redirected_to(conn, 302) =~ "http://another.url?utm_term=#{property.slug}"
    end

    test "it adds to but does not overwrite any existing query strings", %{
      conn: conn
    } do
      user = insert(:user, revenue_rate: Decimal.new(0.3))
      property = insert(:property, user: user)

      impression =
        insert(
          :impression,
          property: property,
          campaign:
            insert(
              :campaign,
              ecpm: Decimal.new(2.00),
              redirect_url: "http://another.url?sure=whatever"
            )
        )

      conn = conn |> put_req_header("user-agent", @user_agent)
      conn = get(conn, track_path(conn, :click, impression))

      impression = CodeFund.Impressions.get_impression!(impression.id)

      assert impression.redirected_to_url ==
               "http://another.url?sure=whatever&utm_term=#{property.slug}"

      refute impression.redirected_at |> is_nil

      assert redirected_to(conn, 302) =~
               "http://another.url?sure=whatever&utm_term=#{property.slug}"
    end
  end
end
