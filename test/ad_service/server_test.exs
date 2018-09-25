defmodule AdService.ServerTest do
  use CodeFundWeb.ConnCase
  import CodeFund.Factory

  setup do
    property = insert(:property)
    {:ok, _pid} = TimeMachinex.ManagedClock.start()

    theme = insert(:theme, slug: "light", template: insert(:template, slug: "default"))

    conn =
      build_conn()
      |> put_req_header(
        "user-agent",
        "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36"
      )

    [cdn_host: cdn_host] = Application.get_env(:code_fund, Framework.FileStorage)

    on_exit(fn -> CodeFundWeb.RedisHelper.clean_redis() end)
    {:ok, %{property: property, theme: theme, conn: conn, cdn_host: cdn_host}}
  end

  describe "serve/3" do
    test "it creates an impression and serves an ad when no cache exists", %{
      conn: conn,
      cdn_host: cdn_host
    } do
      creative = insert(:creative, small_image_asset: insert(:asset))

      audience_1 = insert(:audience, name: "right one")
      audience_2 = insert(:audience, name: "wrong one")

      property =
        insert(
          :property,
          audience: audience_1
        )

      insert(
        :property,
        audience: audience_2
      )

      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0
      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})
      ip_string = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
      redis_key = ip_string <> "/" <> property.id

      assert {:ok, nil} == Redis.Pool.command(["GET", redis_key])

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
          audience: audience_1,
          included_countries: ["US"]
        )

      insert(
        :campaign,
        status: 2,
        ecpm: Decimal.new(2.50),
        budget_daily_amount: Decimal.new(50),
        total_spend: Decimal.new(2000),
        start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
        end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
        creative: creative,
        audience: audience_2,
        included_countries: ["US"]
      )

      advertisement =
        AdService.Server.serve(conn, property.id, %{"height" => 800, "width" => 1200})

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.campaign_id == campaign.id
      assert impression.country == "US"
      assert impression.revenue_amount == Decimal.new("0.002500000000")
      assert impression.distribution_amount == Decimal.new("0.001500000000")
      assert impression.browser_height == 800
      assert impression.browser_width == 1200

      payload = %AdService.AdvertisementImpression{
        small_image_url: Framework.FileStorage.url(creative.small_image_asset.image_object),
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
          }
        ],
        description: "This is a Test Creative",
        large_image_url: Framework.FileStorage.url(creative.large_image_asset.image_object),
        link: "https://www.example.com/c/#{impression.id}",
        pixel: "//www.example.com/p/#{impression.id}/pixel.png",
        poweredByLink: "https://codefund.io?utm_content=#{campaign.id}"
      }

      assert {:ok, payload |> Jason.encode!()} == Redis.Pool.command(["GET", redis_key])
      assert advertisement == payload
    end

    test "excludes us_only_hours campaigns if it is outside of us hours",
         %{conn: conn, cdn_host: cdn_host} do
      TimeMachinex.ManagedClock.set(DateTime.from_naive!(~N[1985-10-26 11:00:00], "Etc/UTC"))
      creative = insert(:creative, small_image_asset: insert(:asset))

      audience_1 = insert(:audience, name: "right one")
      audience_2 = insert(:audience, name: "wrong one")

      property =
        insert(
          :property,
          audience: audience_1
        )

      insert(
        :property,
        audience: audience_2
      )

      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0
      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})

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
          audience: audience_1,
          included_countries: ["US"],
          us_hours_only: false
        )

      insert(
        :campaign,
        status: 2,
        ecpm: Decimal.new(2.50),
        budget_daily_amount: Decimal.new(50),
        total_spend: Decimal.new(2000),
        start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
        end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
        creative: creative,
        audience: audience_1,
        included_countries: ["US"],
        us_hours_only: true
      )

      insert(
        :campaign,
        status: 2,
        ecpm: Decimal.new(2.50),
        budget_daily_amount: Decimal.new(50),
        total_spend: Decimal.new(2000),
        start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
        end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
        creative: creative,
        audience: audience_2,
        included_countries: ["US"]
      )

      advertisement =
        AdService.Server.serve(conn, property.id, %{"height" => 800, "width" => 1200})

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.country == "US"
      assert impression.campaign_id == campaign.id
      assert impression.revenue_amount == Decimal.new("0.002500000000")
      assert impression.distribution_amount == Decimal.new("0.001500000000")
      assert impression.browser_height == 800
      assert impression.browser_width == 1200

      payload = %AdService.AdvertisementImpression{
        small_image_url: Framework.FileStorage.url(creative.small_image_asset.image_object),
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
          }
        ],
        description: "This is a Test Creative",
        large_image_url: Framework.FileStorage.url(creative.large_image_asset.image_object),
        link: "https://www.example.com/c/#{impression.id}",
        pixel: "//www.example.com/p/#{impression.id}/pixel.png",
        poweredByLink: "https://codefund.io?utm_content=#{campaign.id}"
      }

      assert advertisement == payload
    end

    test "serves an ad if property has a campaign tied to an audience but has exceeded impression_count so it records an impression with an error",
         %{conn: conn} do
      creative = insert(:creative, small_image_asset: insert(:asset))

      audience = insert(:audience, name: "right one")

      property =
        insert(
          :property,
          audience: audience
        )

      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0
      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})
      ip_string = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
      redis_key = ip_string <> "/" <> property.id

      assert {:ok, nil} == Redis.Pool.command(["GET", redis_key])

      campaign =
        insert(
          :campaign,
          status: 2,
          ecpm: Decimal.new(2.50),
          budget_daily_amount: Decimal.new(50),
          total_spend: Decimal.new(2000),
          impression_count: 100,
          start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
          end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
          creative: creative,
          audience: audience,
          included_countries: ["US"]
        )

      Redis.Pool.command(["SET", "campaign:#{campaign.id}", "100"])

      advertisement =
        AdService.Server.serve(conn, property.id, %{"height" => 800, "width" => 1200})

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.campaign_id == nil

      assert impression.country == "US"

      assert impression.error_code ==
               AdService.Impression.Errors.fetch_code(:impression_count_exceeded)

      assert impression.revenue_amount |> Decimal.to_integer() == 0
      assert impression.distribution_amount |> Decimal.to_integer() == 0
      assert impression.browser_height == 800
      assert impression.browser_width == 1200

      payload = %AdService.AdvertisementImpression{
        headline: "",
        description: "",
        link: "",
        house_ad: false,
        images: [],
        large_image_url: "",
        small_image_url: "",
        pixel: "//www.example.com/p/#{impression.id}/pixel.png",
        poweredByLink: "https://codefund.io?utm_content=",
        reason: "CodeFund does not have an advertiser for you at this time - code: 1"
      }

      assert advertisement == payload
    end

    test "serves an ad if property has a campaign tied to an audience and creates an impression without height and width",
         %{conn: conn, cdn_host: cdn_host} do
      creative = insert(:creative, small_image_asset: insert(:asset))

      audience_1 = insert(:audience, name: "right one")
      audience_2 = insert(:audience, name: "wrong one")

      property =
        insert(
          :property,
          audience: audience_1
        )

      insert(
        :property,
        audience: audience_2
      )

      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0
      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})
      ip_string = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
      redis_key = ip_string <> "/" <> property.id

      assert {:ok, nil} == Redis.Pool.command(["GET", redis_key])

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
          audience: audience_1,
          included_countries: ["US"]
        )

      insert(
        :campaign,
        status: 2,
        ecpm: Decimal.new(2.50),
        budget_daily_amount: Decimal.new(50),
        total_spend: Decimal.new(2000),
        start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
        end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
        creative: creative,
        audience: audience_2,
        included_countries: ["US"]
      )

      advertisement = AdService.Server.serve(conn, property.id, %{})

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.campaign_id == campaign.id
      assert impression.revenue_amount == Decimal.new("0.002500000000")
      assert impression.distribution_amount == Decimal.new("0.001500000000")
      assert impression.browser_height == nil
      assert impression.country == "US"
      assert impression.browser_width == nil

      payload = %AdService.AdvertisementImpression{
        small_image_url: Framework.FileStorage.url(creative.small_image_asset.image_object),
        headline: "Creative Headline",
        description: "This is a Test Creative",
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
          }
        ],
        large_image_url: Framework.FileStorage.url(creative.large_image_asset.image_object),
        link: "https://www.example.com/c/#{impression.id}",
        pixel: "//www.example.com/p/#{impression.id}/pixel.png",
        poweredByLink: "https://codefund.io?utm_content=#{campaign.id}"
      }

      assert {:ok, payload |> Jason.encode!()} == Redis.Pool.command(["GET", redis_key])
      assert advertisement == payload
    end

    test "returns an error and doesn't create an impression if the traffic is from a bot",
         %{conn: conn} do
      creative = insert(:creative, small_image_asset: insert(:asset))

      audience_1 = insert(:audience, name: "right one")

      property =
        insert(
          :property,
          audience: audience_1
        )

      insert(
        :campaign,
        status: 2,
        ecpm: Decimal.new(2.50),
        budget_daily_amount: Decimal.new(50),
        total_spend: Decimal.new(2000),
        start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
        end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
        creative: creative,
        audience: audience_1,
        included_countries: ["US"]
      )

      conn =
        Plug.Conn.put_req_header(
          conn,
          "user-agent",
          "Googlebot/2.1 (+http://www.googlebot.com/bot.html)"
        )

      advertisement =
        AdService.Server.serve(conn, property.id, %{"height" => 800, "width" => 1200})

      assert CodeFund.Impressions.list_impressions() == []

      assert advertisement == %AdService.AdvertisementImpression{
               headline: "",
               house_ad: false,
               description: "",
               images: [],
               large_image_url: "",
               small_image_url: "",
               link: "",
               pixel: "",
               poweredByLink: "https://codefund.io?utm_content=",
               reason: "CodeFund does not have an advertiser for you at this time"
             }
    end

    test "serves an ad from cache if multiple requests are made to the same property and ip within a time frame and does not create a new impression",
         %{conn: conn, cdn_host: cdn_host} do
      creative = insert(:creative, small_image_asset: insert(:asset))

      audience = insert(:audience)

      property =
        insert(
          :property,
          audience: audience
        )

      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0
      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})
      ip_string = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
      redis_key = ip_string <> "/" <> property.id

      assert {:ok, nil} == Redis.Pool.command(["GET", redis_key])

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

      original_advertisement =
        AdService.Server.serve(conn, property.id, %{"height" => 800, "width" => 1200})

      impression = CodeFund.Impressions.list_impressions() |> List.first()

      payload = %AdService.AdvertisementImpression{
        small_image_url: Framework.FileStorage.url(creative.small_image_asset.image_object),
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
          }
        ],
        description: "This is a Test Creative",
        large_image_url: Framework.FileStorage.url(creative.large_image_asset.image_object),
        link: "https://www.example.com/c/#{impression.id}",
        pixel: "//www.example.com/p/#{impression.id}/pixel.png",
        poweredByLink: "https://codefund.io?utm_content=#{campaign.id}"
      }

      assert {:ok, payload |> Jason.encode!()} == Redis.Pool.command(["GET", redis_key])
      assert original_advertisement == payload
      new_conn = build_conn() |> Map.put(:remote_ip, {12, 109, 12, 14})

      cached_response =
        for {key, val} <-
              AdService.Server.serve(new_conn, property.id, %{"height" => 800, "width" => 1200}),
            into: %{},
            do: {String.to_atom(key), val}

      assert cached_response |> Jason.encode!() == original_advertisement |> Jason.encode!()

      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 1
    end

    test "returns an error if property does not have a campaign but still creates an impression",
         %{conn: conn} do
      creative = insert(:creative)
      property = insert(:property, audience: insert(:audience))
      audience = insert(:audience)

      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0

      insert(
        :campaign,
        status: 2,
        ecpm: Decimal.new(1),
        budget_daily_amount: Decimal.new(1),
        total_spend: Decimal.new(1),
        creative: creative,
        audience: audience
      )

      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})

      advertisement =
        AdService.Server.serve(conn, property.id, %{"height" => 800, "width" => 1200})

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.error_code == AdService.Impression.Errors.fetch_code(:no_possible_ads)
      assert impression.property_id == property.id
      assert impression.campaign_id == nil
      assert impression.country == "US"
      assert impression.browser_height == 800
      assert impression.browser_width == 1200

      assert advertisement == %AdService.AdvertisementImpression{
               headline: "",
               description: "",
               house_ad: false,
               images: [],
               large_image_url: "",
               link: "",
               pixel: "//www.example.com/p/#{impression.id}/pixel.png",
               poweredByLink: "https://codefund.io?utm_content=",
               reason: "CodeFund does not have an advertiser for you at this time - code: 2",
               small_image_url: ""
             }
    end

    test "returns an error if property does not have a campaign but the audience has a fallback ad so it still creates an impression",
         %{conn: conn, cdn_host: cdn_host} do
      creative = insert(:creative, small_image_asset: insert(:asset))

      fallback_campaign =
        insert(:campaign, creative: insert(:creative, small_image_asset: insert(:asset)))

      property =
        insert(:property, audience: insert(:audience, fallback_campaign_id: fallback_campaign.id))

      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0

      insert(
        :campaign,
        status: 2,
        ecpm: Decimal.new(1),
        budget_daily_amount: Decimal.new(1),
        total_spend: Decimal.new(1),
        creative: creative,
        audience: property.audience
      )

      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})

      advertisement =
        AdService.Server.serve(conn, property.id, %{"height" => 800, "width" => 1200})

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.error_code == AdService.Impression.Errors.fetch_code(:no_possible_ads)
      assert impression.property_id == property.id
      assert impression.campaign_id == fallback_campaign.id
      assert impression.browser_height == 800
      assert impression.browser_width == 1200
      assert impression.country == "US"
      assert impression.house_ad == true
      assert impression.revenue_amount |> Decimal.to_integer() == 0
      assert impression.distribution_amount |> Decimal.to_integer() == 0

      assert advertisement == %AdService.AdvertisementImpression{
               small_image_url:
                 Framework.FileStorage.url(
                   fallback_campaign.creative.small_image_asset.image_object
                 ),
               headline: "Creative Headline",
               description: "This is a Test Creative",
               house_ad: true,
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
                 }
               ],
               large_image_url:
                 Framework.FileStorage.url(
                   fallback_campaign.creative.large_image_asset.image_object
                 ),
               link: "https://www.example.com/c/#{impression.id}",
               pixel: "//www.example.com/p/#{impression.id}/pixel.png",
               poweredByLink: "https://codefund.io?utm_content=#{fallback_campaign.id}"
             }
    end

    test "returns an error if property is not active but still creates an impression", %{
      conn: conn
    } do
      property = insert(:property, %{status: 0, audience: insert(:audience)})
      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})
      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0

      advertisement =
        AdService.Server.serve(conn, property.id, %{"height" => 800, "width" => 1200})

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.error_code == AdService.Impression.Errors.fetch_code(:property_inactive)
      assert impression.campaign_id == nil
      assert impression.country == "US"
      assert impression.browser_height == 800
      assert impression.browser_width == 1200

      assert advertisement == %AdService.AdvertisementImpression{
               headline: "",
               description: "",
               link: "",
               house_ad: false,
               images: [],
               large_image_url: "",
               small_image_url: "",
               pixel: "//www.example.com/p/#{impression.id}/pixel.png",
               poweredByLink: "https://codefund.io?utm_content=",
               reason: "This property is not currently active - code: 0"
             }
    end

    test "returns an error if viewer is from a blocked country but still creates an impression",
         %{conn: conn} do
      property = insert(:property, audience: insert(:audience))
      conn = conn |> Map.put(:remote_ip, {163, 177, 112, 32})

      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0

      advertisement =
        AdService.Server.serve(conn, property.id, %{"height" => 800, "width" => 1200})

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "163.177.112.32"

      assert impression.property_id == property.id
      assert impression.campaign_id == nil
      assert impression.country == "CN"
      assert impression.error_code == AdService.Impression.Errors.fetch_code(:no_possible_ads)

      assert advertisement == %AdService.AdvertisementImpression{
               headline: "",
               description: "",
               house_ad: false,
               images: [],
               link: "",
               large_image_url: "",
               small_image_url: "",
               pixel: "//www.example.com/p/#{impression.id}/pixel.png",
               poweredByLink: "https://codefund.io?utm_content=",
               reason: "CodeFund does not have an advertiser for you at this time - code: 2"
             }
    end

    test "returns an error if property is not assigned to an audience", %{
      conn: conn
    } do
      property = insert(:property)
      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})
      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0

      advertisement =
        AdService.Server.serve(conn, property.id, %{"height" => 800, "width" => 1200})

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.campaign_id == nil
      assert impression.country == "US"
      assert impression.error_code == AdService.Impression.Errors.fetch_code(:property_inactive)

      assert advertisement == %AdService.AdvertisementImpression{
               headline: "",
               description: "",
               link: "",
               house_ad: false,
               images: [],
               large_image_url: "",
               small_image_url: "",
               pixel: "//www.example.com/p/#{impression.id}/pixel.png",
               poweredByLink: "https://codefund.io?utm_content=",
               reason: "This property is not currently active - code: 0"
             }
    end
  end
end
