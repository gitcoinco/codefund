defmodule CodeFundWeb.TrackControllerTest do
  use CodeFundWeb.ConnCase
  import CodeFund.Factory

  # import Mock

  @user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"
  @bot_agent  "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"

  setup do
    transparent_png = <<71, 73, 70, 56, 57, 97, 1, 0, 1, 0, 128, 0, 0, 0, 0, 0, 255, 255, 255, 33, 249, 4, 1, 0, 0, 0, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 1, 68, 0, 59>>
    {:ok, %{transparent_png: transparent_png}}
  end

  describe "pixel/2" do
    test "Creates impression and renders a transparent png", %{conn: conn, transparent_png: transparent_png} do
      user        = insert(:user)
      campaign    = insert(:campaign)
      sponsorship = insert(:sponsorship, bid_amount: Decimal.new(1.25), campaign: campaign)
      property    = insert(:property, user: user, sponsorship: sponsorship)

      conn =
        conn
        |> put_req_header("user-agent", @user_agent)
        |> get("/t/l/#{property.id}/pixel.png")

      content_type  = conn |> get_resp_header("content-type") |> Enum.at(0)
      impression_id = conn.private[:impression_id]

      assert content_type == "image/png; charset=utf-8"
      assert String.length(impression_id) == 36 # uuid
      assert conn.resp_body == transparent_png
    end

    test "Creates impression and renders a transparent png with sponsorship", %{conn: conn, transparent_png: transparent_png} do
      user        = insert(:user)
      campaign    = insert(:campaign)
      sponsorship = insert(:sponsorship, bid_amount: Decimal.new(1.25), campaign: campaign)
      property    = insert(:property, user: user, sponsorship: sponsorship)

      conn =
        conn
        |> put_req_header("user-agent", @user_agent)
        |> get("/t/p/#{sponsorship.id}/pixel.png")

      content_type  = conn |> get_resp_header("content-type") |> Enum.at(0)
      impression_id = conn.private[:impression_id]

      assert content_type == "image/png; charset=utf-8"
      assert String.length(impression_id) == 36 # uuid
      assert conn.resp_body == transparent_png
    end

    test "Does not create an impression when property is invalid", %{conn: conn, transparent_png: transparent_png} do
      conn =
        conn
        |> put_req_header("user-agent", @user_agent)
        |> get("/t/l/5a04fdde-1358-4249-a69b-6283e9b4d432/pixel.png")

      content_type  = conn |> get_resp_header("content-type") |> Enum.at(0)
      impression_id = conn.private[:impression_id]

      assert content_type == "image/png; charset=utf-8"
      assert String.length(impression_id) == 0
      assert conn.resp_body == transparent_png
    end

    test "Creates an impression when sponsorship is missing", %{conn: conn, transparent_png: transparent_png} do
      user     = insert(:user)
      property = insert(:property, user: user, sponsorship: nil)

      conn =
        conn
        |> put_req_header("user-agent", @user_agent)
        |> get("/t/l/#{property.id}/pixel.png")

      content_type  = conn |> get_resp_header("content-type") |> Enum.at(0)
      impression_id = conn.private[:impression_id]

      assert content_type == "image/png; charset=utf-8"
      assert String.length(impression_id) == 36
      assert conn.resp_body == transparent_png
    end

    test "Creates an impression when browser is a bot", %{conn: conn, transparent_png: transparent_png} do
      user        = insert(:user)
      campaign    = insert(:campaign)
      sponsorship = insert(:sponsorship, bid_amount: Decimal.new(1.25), campaign: campaign)
      property    = insert(:property, user: user, sponsorship: sponsorship)

      conn =
        conn
        |> put_req_header("user-agent", @bot_agent)
        |> get("/t/l/#{property.id}/pixel.png")

      content_type  = conn |> get_resp_header("content-type") |> Enum.at(0)
      impression_id = conn.private[:impression_id]

      assert content_type == "image/png; charset=utf-8"
      assert String.length(impression_id) == 36 # uuid
      assert conn.resp_body == transparent_png

      impression = CodeFund.Impressions.get_impression!(impression_id)
      assert impression.is_bot
    end
  end

#  describe "click/2" do
#    test "Creates a click and redirects the visitor and assigns revenue/distribution"
#    test "Does not create click when property is missing"
#    test "Creates a click when sponsorship is missing"
#    test "Creates a click when bot"
#    test "Creates a click when duplicate"
#  end

end
