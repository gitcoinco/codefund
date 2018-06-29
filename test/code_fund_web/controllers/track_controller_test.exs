defmodule CodeFundWeb.TrackControllerTest do
  use CodeFundWeb.ConnCase

  @user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"

  setup do
    transparent_png =
      <<71, 73, 70, 56, 57, 97, 1, 0, 1, 0, 128, 0, 0, 0, 0, 0, 255, 255, 255, 33, 249, 4, 1, 0,
        0, 0, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 1, 68, 0, 59>>

    {:ok, %{transparent_png: transparent_png}}
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
      assert impression.ip == "127.0.0.1"

      assert impression.user_agent ==
               "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"

      assert impression.os == "mac"
      assert impression.device_type == "desktop"
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
