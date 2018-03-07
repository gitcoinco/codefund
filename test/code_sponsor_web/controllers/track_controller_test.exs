defmodule CodeSponsorWeb.TrackControllerTest do
  use CodeSponsorWeb.ConnCase
  import CodeSponsor.Factory

  # import Mock

  @user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"
  @bot_agent  "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"

  describe "pixel/2" do
    test "Creates impression and renders a transparent png", %{conn: conn} do
      user        = insert(:user)
      campaign    = insert(:campaign)
      sponsorship = insert(:sponsorship, bid_amount: Decimal.new(1.25), campaign: campaign)
      property    = insert(:property, user: user, sponsorship: sponsorship)

      conn =
        conn
        |> put_req_header("user-agent", @user_agent)
        |> get(track_path(conn, :pixel, property.id))

      content_type  = conn |> get_resp_header("content-type") |> Enum.at(0)
      impression_id = conn.private[:impression_id]

      assert content_type == "image/png; charset=utf-8"
      assert String.length(impression_id) == 36 # uuid
      assert conn.resp_body == CodeSponsorWeb.TrackController.transparent_png
    end

    test "Does not create an impression when property is invalid", %{conn: conn} do
      conn =
        conn
        |> put_req_header("user-agent", @user_agent)
        |> get(track_path(conn, :pixel, "12345"))

      content_type  = conn |> get_resp_header("content-type") |> Enum.at(0)
      impression_id = conn.private[:impression_id]
      
      assert content_type == "image/png; charset=utf-8"
      assert String.length(impression_id) == 0
      assert conn.resp_body == CodeSponsorWeb.TrackController.transparent_png
    end

    test "Creates an impression when sponsorship is missing", %{conn: conn} do
      user     = insert(:user)
      property = insert(:property, user: user, sponsorship: nil)

      conn =
        conn
        |> put_req_header("user-agent", @user_agent)
        |> get(track_path(conn, :pixel, property.id))

      content_type  = conn |> get_resp_header("content-type") |> Enum.at(0)
      impression_id = conn.private[:impression_id]
      
      assert content_type == "image/png; charset=utf-8"
      assert String.length(impression_id) == 36
      assert conn.resp_body == CodeSponsorWeb.TrackController.transparent_png
    end

    test "Creates an impression when browser is a bot", %{conn: conn} do
      user        = insert(:user)
      campaign    = insert(:campaign)
      sponsorship = insert(:sponsorship, bid_amount: Decimal.new(1.25), campaign: campaign)
      property    = insert(:property, user: user, sponsorship: sponsorship)

      conn =
        conn
        |> put_req_header("user-agent", @bot_agent)
        |> get(track_path(conn, :pixel, property.id))

      content_type  = conn |> get_resp_header("content-type") |> Enum.at(0)
      impression_id = conn.private[:impression_id]

      assert content_type == "image/png; charset=utf-8"
      assert String.length(impression_id) == 36 # uuid
      assert conn.resp_body == CodeSponsorWeb.TrackController.transparent_png

      impression = CodeSponsor.Impressions.get_impression!(impression_id)
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