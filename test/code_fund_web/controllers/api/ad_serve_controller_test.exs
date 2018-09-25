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

    [cdn_host: cdn_host] = Application.get_env(:code_fund, Framework.FileStorage)

    on_exit(fn -> CodeFundWeb.RedisHelper.clean_redis() end)
    {:ok, %{property: property, theme: theme, conn: conn, cdn_host: cdn_host}}
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
      assert json_response(conn, 200) |> Jason.encode!() == payload |> Jason.encode!()
    end
  end
end
