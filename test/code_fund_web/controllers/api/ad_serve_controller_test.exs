defmodule CodeFundWeb.API.AdServeControllerTest do
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

    on_exit(fn -> CodeFundWeb.RedisHelper.clean_redis() end)
    {:ok, %{property: property, theme: theme, conn: conn}}
  end

  describe "embed" do
    test "it uses the default template", %{conn: conn, property: property} do
      conn = get(conn, ad_serve_path(conn, :embed, property.id))
      assert response(conn, 200)
      assert conn.assigns.template.slug == "default"
    end

    test "it uses the requested template", %{conn: conn, property: property} do
      insert(:theme, slug: "light", template: insert(:template, slug: "custom"))
      conn = get(conn, ad_serve_path(conn, :embed, property.id, template: "custom"))
      assert response(conn, 200)
      assert conn.assigns.template.slug == "custom"
    end

    test "it uses the override template defined on the property", %{conn: conn} do
      template = insert(:template, slug: "override")
      property = insert(:property, template: template)
      insert(:theme, slug: "light", template: template)
      conn = get(conn, ad_serve_path(conn, :embed, property.id))
      assert response(conn, 200)
      assert conn.assigns.template.slug == "override"
    end

    test "it uses the override template defined on the property even when a different template was requested",
         %{conn: conn} do
      template = insert(:template, slug: "override")
      property = insert(:property, template: template)
      insert(:theme, slug: "light", template: template)
      conn = get(conn, ad_serve_path(conn, :embed, property.id, template: "default"))
      assert response(conn, 200)
      assert conn.assigns.template.slug == "override"
    end

    test "it returns template and theme if one is found", %{
      conn: conn,
      property: property,
      theme: theme
    } do
      conn = get(conn, ad_serve_path(conn, :embed, property.id))
      assert response(conn, 200)
      assert conn.resp_body =~ "_codefund_theme"
      assert conn.private.phoenix_template == "embed.js"
      assert conn.assigns.template == theme.template
      assert conn.assigns.targetId == "codefund_ad"
      assert conn.assigns.theme == theme
      assert conn.assigns.details_url == "https://#{conn.host}/t/s/#{property.id}/details.json"
    end

    test "it returns 404 if theme is not found", %{conn: conn, property: property} do
      template = insert(:template, slug: "other")
      insert(:theme, slug: "light", template_id: template.id)
      insert(:theme, slug: "dark", template_id: template.id)

      conn =
        get(
          conn,
          ad_serve_path(conn, :embed, property.id, template: "other", theme: "does_not_exist")
        )

      assert response(conn, 404) ==
               "console.log('CodeFund theme does not exist. Available themes are [dark|light]');"
    end

    test "it returns 404 if template is not found", %{conn: conn, property: property} do
      insert(:template, slug: "some_template")
      insert(:template, slug: "other")
      conn = get(conn, ad_serve_path(conn, :embed, property.id, template: "does_not_exist"))

      assert response(conn, 404) ==
               "console.log('CodeFund template does not exist. Available templates are [default|some_template|other]');"
    end
  end

  describe "details" do
    test "serves an ad if property has a campaign tied to an audience and creates an impression and records distribution and revenue amounts",
         %{conn: conn} do
      creative = insert(:creative)

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

      conn =
        get(conn, ad_serve_path(conn, :details, property, %{"height" => 800, "width" => 1200}))

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.campaign_id == campaign.id
      assert impression.country == "US"
      assert impression.revenue_amount == Decimal.new("0.002500000000")
      assert impression.distribution_amount == Decimal.new("0.001500000000")
      assert impression.browser_height == 800
      assert impression.browser_width == 1200

      payload = %{
        "small_image_url" => Framework.FileStorage.url(creative.small_image_object),
        "headline" => "Creative Headline",
        "description" => "This is a Test Creative",
        "large_image_url" => Framework.FileStorage.url(creative.large_image_object),
        "image" => "http://example.com/some.png",
        "link" => "https://www.example.com/c/#{impression.id}",
        "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
        "poweredByLink" => "https://codefund.io?utm_content=#{campaign.id}"
      }

      assert {:ok, payload |> Poison.encode!()} == Redis.Pool.command(["GET", redis_key])
      assert json_response(conn, 200) == payload
    end

    test "excludes us_only_hours campaigns if it is outside of us hours",
         %{conn: conn} do
      TimeMachinex.ManagedClock.set(DateTime.from_naive!(~N[1985-10-26 11:00:00], "Etc/UTC"))
      creative = insert(:creative)

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

      conn =
        get(conn, ad_serve_path(conn, :details, property, %{"height" => 800, "width" => 1200}))

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.country == "US"
      assert impression.campaign_id == campaign.id
      assert impression.revenue_amount == Decimal.new("0.002500000000")
      assert impression.distribution_amount == Decimal.new("0.001500000000")
      assert impression.browser_height == 800
      assert impression.browser_width == 1200

      payload = %{
        "small_image_url" => Framework.FileStorage.url(creative.small_image_object),
        "headline" => "Creative Headline",
        "description" => "This is a Test Creative",
        "large_image_url" => Framework.FileStorage.url(creative.large_image_object),
        "image" => "http://example.com/some.png",
        "link" => "https://www.example.com/c/#{impression.id}",
        "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
        "poweredByLink" => "https://codefund.io?utm_content=#{campaign.id}"
      }

      assert json_response(conn, 200) == payload
    end

    test "serves an ad if property has a campaign tied to an audience but has exceeded impression_count so it records an impression with an error",
         %{conn: conn} do
      creative = insert(:creative)

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

      conn =
        get(conn, ad_serve_path(conn, :details, property, %{"height" => 800, "width" => 1200}))

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.campaign_id == nil

      assert impression.country == "US"

      assert impression.error_code ==
               AdService.ImpressionErrors.fetch_code(:impression_count_exceeded)

      assert impression.revenue_amount |> Decimal.to_integer() == 0
      assert impression.distribution_amount |> Decimal.to_integer() == 0
      assert impression.browser_height == 800
      assert impression.browser_width == 1200

      assert json_response(conn, 200) == %{
               "headline" => "",
               "description" => "",
               "image" => "",
               "link" => "",
               "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=",
               "reason" => "CodeFund does not have an advertiser for you at this time - code: 1"
             }
    end

    test "serves an ad if property has a campaign tied to an audience and creates an impression without height and width",
         %{conn: conn} do
      creative = insert(:creative)

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

      conn = get(conn, ad_serve_path(conn, :details, property))

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.campaign_id == campaign.id
      assert impression.revenue_amount == Decimal.new("0.002500000000")
      assert impression.distribution_amount == Decimal.new("0.001500000000")
      assert impression.browser_height == nil
      assert impression.country == "US"
      assert impression.browser_width == nil

      payload = %{
        "small_image_url" => Framework.FileStorage.url(creative.small_image_object),
        "headline" => "Creative Headline",
        "description" => "This is a Test Creative",
        "large_image_url" => Framework.FileStorage.url(creative.large_image_object),
        "image" => "http://example.com/some.png",
        "link" => "https://www.example.com/c/#{impression.id}",
        "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
        "poweredByLink" => "https://codefund.io?utm_content=#{campaign.id}"
      }

      assert {:ok, payload |> Poison.encode!()} == Redis.Pool.command(["GET", redis_key])
      assert json_response(conn, 200) == payload
    end

    test "returns an error and doesn't create an impression if the traffic is from a bot",
         %{conn: conn} do
      creative = insert(:creative)

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

      conn =
        get(conn, ad_serve_path(conn, :details, property, %{"height" => 800, "width" => 1200}))

      assert CodeFund.Impressions.list_impressions() == []

      assert json_response(conn, 200) == %{
               "headline" => "",
               "description" => "",
               "image" => "",
               "link" => "",
               "pixel" => "",
               "poweredByLink" => "https://codefund.io?utm_content=",
               "reason" => "CodeFund does not have an advertiser for you at this time"
             }
    end

    test "serves an ad from cache if multiple requests are made to the same property and ip within a time frame and does not create a new impression",
         %{conn: conn} do
      creative = insert(:creative)

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

      conn =
        get(conn, ad_serve_path(conn, :details, property, %{"height" => 800, "width" => 1200}))

      initial_response = conn |> json_response(200)

      impression = CodeFund.Impressions.list_impressions() |> List.first()

      payload = %{
        "small_image_url" => Framework.FileStorage.url(creative.small_image_object),
        "headline" => "Creative Headline",
        "description" => "This is a Test Creative",
        "large_image_url" => Framework.FileStorage.url(creative.large_image_object),
        "image" => "http://example.com/some.png",
        "link" => "https://www.example.com/c/#{impression.id}",
        "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
        "poweredByLink" => "https://codefund.io?utm_content=#{campaign.id}"
      }

      assert {:ok, payload |> Poison.encode!()} == Redis.Pool.command(["GET", redis_key])
      assert json_response(conn, 200) == payload
      new_conn = build_conn() |> Map.put(:remote_ip, {12, 109, 12, 14})

      assert get(
               new_conn,
               ad_serve_path(conn, :details, property, %{"height" => 800, "width" => 1200})
             )
             |> json_response(200) == initial_response

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

      conn =
        get(conn, ad_serve_path(conn, :details, property, %{"height" => 800, "width" => 1200}))

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.error_code == AdService.ImpressionErrors.fetch_code(:no_possible_ads)
      assert impression.property_id == property.id
      assert impression.campaign_id == nil
      assert impression.country == "US"
      assert impression.browser_height == 800
      assert impression.browser_width == 1200

      assert json_response(conn, 200) == %{
               "headline" => "",
               "description" => "",
               "image" => "",
               "link" => "",
               "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=",
               "reason" => "CodeFund does not have an advertiser for you at this time - code: 2"
             }
    end

    test "returns an error if property does not have a campaign but the audience has a fallback ad so it still creates an impression",
         %{conn: conn} do
      creative = insert(:creative)
      fallback_campaign = insert(:campaign)

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

      conn =
        get(conn, ad_serve_path(conn, :details, property, %{"height" => 800, "width" => 1200}))

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.error_code == AdService.ImpressionErrors.fetch_code(:no_possible_ads)
      assert impression.property_id == property.id
      assert impression.campaign_id == fallback_campaign.id
      assert impression.browser_height == 800
      assert impression.browser_width == 1200
      assert impression.country == "US"
      assert impression.house_ad == true
      assert impression.revenue_amount |> Decimal.to_integer() == 0
      assert impression.distribution_amount |> Decimal.to_integer() == 0

      assert json_response(conn, 200) == %{
               "small_image_url" => Framework.FileStorage.url(creative.small_image_object),
               "headline" => "Creative Headline",
               "description" => "This is a Test Creative",
               "large_image_url" => Framework.FileStorage.url(creative.large_image_object),
               "image" => "http://example.com/some.png",
               "link" => "https://www.example.com/c/#{impression.id}",
               "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=#{fallback_campaign.id}"
             }
    end

    test "returns an error if property is not active but still creates an impression", %{
      conn: conn
    } do
      property = insert(:property, %{status: 0, audience: insert(:audience)})
      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})
      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0

      conn =
        get(conn, ad_serve_path(conn, :details, property, %{"height" => 800, "width" => 1200}))

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.error_code == AdService.ImpressionErrors.fetch_code(:property_inactive)
      assert impression.campaign_id == nil
      assert impression.country == "US"
      assert impression.browser_height == 800
      assert impression.browser_width == 1200

      assert json_response(conn, 200) == %{
               "headline" => "",
               "description" => "",
               "image" => "",
               "link" => "",
               "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=",
               "reason" => "This property is not currently active - code: 0"
             }
    end

    test "returns an error if viewer is from a blocked country but still creates an impression",
         %{conn: conn} do
      property = insert(:property, audience: insert(:audience))
      conn = conn |> Map.put(:remote_ip, {163, 177, 112, 32})

      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0

      conn =
        get(conn, ad_serve_path(conn, :details, property, %{"height" => 800, "width" => 1200}))

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "163.177.112.32"

      assert impression.property_id == property.id
      assert impression.campaign_id == nil
      assert impression.country == "CN"
      assert impression.error_code == AdService.ImpressionErrors.fetch_code(:no_possible_ads)

      assert json_response(conn, 200) == %{
               "headline" => "",
               "description" => "",
               "image" => "",
               "link" => "",
               "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=",
               "reason" => "CodeFund does not have an advertiser for you at this time - code: 2"
             }
    end

    test "returns an error if property is not assigned to an audience", %{
      conn: conn
    } do
      property = insert(:property)
      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})
      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0

      conn =
        get(conn, ad_serve_path(conn, :details, property, %{"height" => 800, "width" => 1200}))

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.campaign_id == nil
      assert impression.country == "US"
      assert impression.error_code == AdService.ImpressionErrors.fetch_code(:property_inactive)

      assert json_response(conn, 200) == %{
               "headline" => "",
               "description" => "",
               "image" => "",
               "link" => "",
               "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=",
               "reason" => "This property is not currently active - code: 0"
             }
    end
  end
end
