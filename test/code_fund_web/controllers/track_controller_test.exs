defmodule CodeFundWeb.TrackControllerTest do
  use CodeFundWeb.ConnCase

  @user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"
  @bot_agent "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"

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

    test "Creates an impression when browser is a bot", %{
      conn: conn,
      transparent_png: transparent_png
    } do
      impression = insert(:impression)

      conn =
        conn
        |> put_req_header("user-agent", @bot_agent)
        |> get("/p/#{impression.id}/pixel.png")

      content_type = conn |> get_resp_header("content-type") |> Enum.at(0)

      assert content_type == "image/png; charset=utf-8"

      assert conn.resp_body == transparent_png

      impression = CodeFund.Impressions.get_impression!(impression.id)
      assert impression.ip == "127.0.0.1"

      assert impression.user_agent ==
               "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"

      assert impression.os == "other"
      assert impression.device_type == "unknown"
    end
  end

  describe "click/2" do
    test "Creates a click and redirects the visitor and assigns revenue/distribution if the campaign has a fraud check url but the user was successfully redirected",
         %{
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
              bid_amount: Decimal.new(2.00),
              override_revenue_rate: nil,
              fraud_check_url: "http://example.com",
              redirect_url: "http://another.url"
            )
        )

      assert CodeFund.Clicks.list_clicks() |> Enum.count() == 0
      conn = conn |> put_req_header("user-agent", @user_agent)
      conn = get(conn, track_path(conn, :click, impression))

      {:ok, click} =
        CodeFund.Clicks.list_clicks()
        |> List.first()
        |> CodeFund.Clicks.update_click(%{status: 1})

      :timer.sleep(300)
      assert click.impression_id == impression.id
      refute is_nil(click.fraud_check_redirected_at)
      assert click.distribution_amount == Decimal.new("0.60")
      assert click.revenue_amount == Decimal.new("0.60")
      assert click.status == CodeFund.Schema.Click.statuses()[:redirected]

      assert redirected_to(conn, 302) =~ "http://example.com"
    end

    test "Creates a click and redirects the visitor and assigns revenue/distribution if the campaign has a fraud check url but the user was not successfully redirected",
         %{
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
              bid_amount: Decimal.new(2.00),
              override_revenue_rate: nil,
              fraud_check_url: "http://example.com",
              redirect_url: "http://another.url"
            )
        )

      assert CodeFund.Clicks.list_clicks() |> Enum.count() == 0
      conn = conn |> put_req_header("user-agent", @user_agent)
      conn = get(conn, track_path(conn, :click, impression))
      :timer.sleep(300)
      click = CodeFund.Clicks.list_clicks() |> List.first()
      assert click.impression_id == impression.id
      refute is_nil(click.fraud_check_redirected_at)
      assert click.distribution_amount == Decimal.new("0.00")
      assert click.revenue_amount == Decimal.new("0.00")
      assert click.status == CodeFund.Schema.Click.statuses()[:fraud]

      assert redirected_to(conn, 302) =~ "http://example.com"
    end

    test "Creates a click and redirects the visitor and assigns revenue/distribution if the campaign does not have a fraud check url",
         %{
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
              bid_amount: Decimal.new(2.00),
              override_revenue_rate: nil,
              fraud_check_url: nil,
              redirect_url: "http://another.url"
            )
        )

      assert CodeFund.Clicks.list_clicks() |> Enum.count() == 0
      conn = conn |> put_req_header("user-agent", @user_agent)
      conn = get(conn, track_path(conn, :click, impression))
      click = CodeFund.Clicks.list_clicks() |> List.first()
      assert click.impression_id == impression.id
      assert is_nil(click.fraud_check_redirected_at)
      assert click.distribution_amount == Decimal.new("0.60")
      assert click.revenue_amount == Decimal.new("0.60")
      assert click.ip == "127.0.0.1"

      assert click.user_agent ==
               "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"

      assert click.os == "mac"
      assert click.device_type == "desktop"
      refute click.is_bot
      refute click.is_duplicate
      assert click.status == CodeFund.Schema.Click.statuses()[:redirected]
      assert redirected_to(conn, 302) =~ "http://another.url"
    end

    test "Creates a click and redirects the visitor and assigns revenue/distribution if there's a campaign override revenue rate",
         %{
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
              bid_amount: Decimal.new(2.00),
              override_revenue_rate: Decimal.new(0.2),
              fraud_check_url: nil,
              redirect_url: "http://another.url"
            )
        )

      assert CodeFund.Clicks.list_clicks() |> Enum.count() == 0
      conn = conn |> put_req_header("user-agent", @user_agent)
      conn = get(conn, track_path(conn, :click, impression))
      click = CodeFund.Clicks.list_clicks() |> List.first()
      assert click.impression_id == impression.id
      assert is_nil(click.fraud_check_redirected_at)
      assert click.distribution_amount == Decimal.new("0.40")
      assert click.revenue_amount == Decimal.new("0.40")
      assert click.ip == "127.0.0.1"

      assert click.user_agent ==
               "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"

      assert click.os == "mac"
      assert click.device_type == "desktop"
      assert click.status == CodeFund.Schema.Click.statuses()[:redirected]
      refute click.is_bot
      refute click.is_duplicate
      assert redirected_to(conn, 302) =~ "http://another.url"
    end

    test "Creates a click when bot", %{conn: conn} do
      user = insert(:user, revenue_rate: Decimal.new(0.3))
      property = insert(:property, user: user)

      impression =
        insert(
          :impression,
          property: property,
          campaign:
            insert(
              :campaign,
              bid_amount: Decimal.new(2.00),
              override_revenue_rate: nil,
              fraud_check_url: nil,
              redirect_url: "http://another.url"
            )
        )

      assert CodeFund.Clicks.list_clicks() |> Enum.count() == 0
      conn = conn |> put_req_header("user-agent", @bot_agent)
      conn = get(conn, track_path(conn, :click, impression))
      click = CodeFund.Clicks.list_clicks() |> List.first()
      assert click.impression_id == impression.id
      assert is_nil(click.fraud_check_redirected_at)
      assert click.distribution_amount == Decimal.new("0.00")
      assert click.revenue_amount == Decimal.new("0.00")
      assert click.ip == "127.0.0.1"
      assert click.status == CodeFund.Schema.Click.statuses()[:redirected]

      assert click.user_agent ==
               "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"

      assert click.os == "other"
      assert click.device_type == "unknown"
      assert click.is_bot
      refute click.is_duplicate
      assert redirected_to(conn, 302) =~ "http://another.url"
    end

    test "Creates a click when duplicate", %{conn: conn} do
      user = insert(:user, revenue_rate: Decimal.new(0.3))
      property = insert(:property, user: user)

      impression =
        insert(
          :impression,
          property: property,
          campaign:
            insert(
              :campaign,
              bid_amount: Decimal.new(2.00),
              override_revenue_rate: nil,
              fraud_check_url: nil,
              redirect_url: "http://another.url"
            )
        )

      assert CodeFund.Clicks.list_clicks() |> Enum.count() == 0
      conn = conn |> put_req_header("user-agent", @user_agent)
      get(conn, track_path(conn, :click, impression))
      conn = get(conn, track_path(conn, :click, impression))
      click = CodeFund.Clicks.list_clicks() |> List.last()
      assert click.impression_id == impression.id
      assert is_nil(click.fraud_check_redirected_at)
      assert click.distribution_amount == Decimal.new("0.00")
      assert click.revenue_amount == Decimal.new("0.00")
      assert click.ip == "127.0.0.1"
      assert click.status === CodeFund.Schema.Click.statuses()[:redirected]

      assert click.user_agent ==
               "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"

      assert click.os == "mac"
      assert click.device_type == "desktop"
      refute click.is_bot
      assert click.is_duplicate
      assert redirected_to(conn, 302) =~ "http://another.url"
    end
  end
end
