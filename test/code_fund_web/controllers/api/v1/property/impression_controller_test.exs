defmodule CodeFundWeb.API.V1.Property.ImpressionControllerTest do
  use CodeFundWeb.ConnCase
  import CodeFund.Factory

  setup do
    {:ok, _pid} = TimeMachinex.ManagedClock.start()
    creative = insert(:creative, wide_image_asset: insert(:asset))

    audience = insert(:audience, name: "right one")

    property =
      insert(
        :property,
        audience: audience
      )

    campaign =
      insert(
        :campaign,
        status: 2,
        ecpm: Decimal.new(2.50),
        budget_daily_amount: Decimal.new(50),
        total_spend: Decimal.new(2000),
        start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
        end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
        creative: creative,
        audience: audience,
        included_countries: ["US"]
      )

    conn =
      build_conn()
      |> put_req_header(
        "user-agent",
        "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36"
      )

    users = %{
      api_user: insert(:user, %{api_access: true, api_key: "1234567890"}),
      non_api_user: insert(:user, %{api_key: "12345"})
    }

    on_exit(fn -> CodeFundWeb.RedisHelper.clean_redis() end)
    {:ok, %{property: property, conn: conn, users: users, campaign: campaign, creative: creative}}
  end

  describe "POST Create" do
    test "it fails if the user doesn't have api access", %{
      property: property,
      conn: conn,
      users: users
    } do
      conn = conn |> put_req_header("x-codefund-api-key", users.non_api_user.api_key)
      conn = post(conn, api_property_impression_path(conn, :create, property.id))
      assert json_response(conn, 401) == %{"error" => "You do not have access to the API."}
    end

    test "it fails if the api_key is invalid", %{property: property, conn: conn} do
      conn = conn |> put_req_header("x-codefund-api-key", "98765")
      conn = post(conn, api_property_impression_path(conn, :create, property.id))
      assert json_response(conn, 401) == %{"error" => "You do not have access to the API."}
    end

    test "it fails if the ip_address is missing from the post body", %{
      property: property,
      conn: conn,
      users: users
    } do
      conn = conn |> put_req_header("x-codefund-api-key", users.api_user.api_key)
      conn = post(conn, api_property_impression_path(conn, :create, property.id))

      assert json_response(conn, 422) == %{
               "error" => "Client's IP Address is required (`ip_address` parameter in post body)"
             }
    end

    test "it renders the details json", %{
      property: property,
      conn: conn,
      users: users,
      campaign: campaign,
      creative: creative
    } do
      [cdn_host: cdn_host] = Application.get_env(:code_fund, Framework.FileStorage)

      conn = conn |> put_req_header("x-codefund-api-key", users.api_user.api_key)

      conn =
        post(
          conn,
          api_property_impression_path(conn, :create, property.id, %{
            "ip_address" => "12.109.12.14",
            "height" => 200,
            "width" => "300",
            "user_agent" => "Chrome"
          })
        )

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.campaign_id == campaign.id
      assert impression.country == "US"
      assert impression.revenue_amount == Decimal.new("0.002500000000")
      assert impression.distribution_amount == Decimal.new("0.001500000000")
      assert impression.browser_height == 200
      assert impression.browser_width == 300
      assert impression.user_agent == "Chrome"

      assert json_response(conn, 200) |> Jason.encode!() ==
               %AdService.AdvertisementImpression{
                 small_image_url:
                   Framework.FileStorage.url(creative.small_image_asset.image_object),
                 headline: "Creative Headline",
                 house_ad: false,
                 images: [
                   %AdService.ImageAsset{
                     height: 200,
                     size_descriptor: "small",
                     url: "https://#{cdn_host}/image.jpg",
                     width: 200
                   },
                   %AdService.ImageAsset{
                     height: 200,
                     size_descriptor: "large",
                     url: "https://#{cdn_host}/image.jpg",
                     width: 280
                   },
                   %AdService.ImageAsset{
                     height: 512,
                     size_descriptor: "wide",
                     url: "https://#{cdn_host}/image.jpg",
                     width: 320
                   }
                 ],
                 description: "This is a Test Creative",
                 large_image_url:
                   Framework.FileStorage.url(creative.large_image_asset.image_object),
                 link: "https://www.example.com/c/#{impression.id}",
                 pixel: "//www.example.com/p/#{impression.id}/pixel.png",
                 poweredByLink: "https://codefund.io?utm_content=#{campaign.id}"
               }
               |> Jason.encode!()
    end
  end
end
