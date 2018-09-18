defmodule AdService.Impression.ManagerTest do
  use CodeFundWeb.ConnCase
  import CodeFund.Factory

  setup do
    conn =
      build_conn()
      |> put_req_header(
        "user-agent",
        "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36"
      )
      |> Map.put(:remote_ip, {12, 109, 12, 14})

    property = insert(:property)
    campaign = insert(:campaign)

    impression_details = AdService.Impression.Details.new(conn, property, campaign)

    [cdn_host: cdn_host] = Application.get_env(:code_fund, Framework.FileStorage)

    advertisement = %AdService.Advertisement{
      body: "This is a Test Creative",
      campaign_id: impression_details.campaign.id,
      campaign_name: "Test Campaign",
      ecpm: Decimal.new("2.50"),
      headline: "Creative Headline",
      large_image_object: "image.jpg",
      small_image_object: "image.jpg"
    }

    on_exit(fn -> CodeFundWeb.RedisHelper.clean_redis() end)

    {:ok,
     %{
       conn: conn,
       impression_details: impression_details,
       advertisement: advertisement,
       cdn_host: cdn_host
     }}
  end

  describe "create_successful_impression/2" do
    test "it creates a successful impression and returns a response map for success", %{
      impression_details: impression_details,
      advertisement: advertisement,
      cdn_host: cdn_host
    } do
      payload =
        AdService.Impression.Manager.create_successful_impression(
          impression_details,
          advertisement
        )

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == impression_details.property.id
      assert impression.country == "US"
      assert impression.campaign_id == impression_details.campaign.id
      assert impression.revenue_amount == Decimal.new("0.002000000000")
      assert impression.distribution_amount == Decimal.new("0.001200000000")

      assert %{
               description: "This is a Test Creative",
               headline: "Creative Headline",
               house_ad: false,
               large_image_url: "https://#{cdn_host}/image.jpg",
               link: "https://www.example.com/c/#{impression.id}",
               pixel: "//www.example.com/p/#{impression.id}/pixel.png",
               poweredByLink: "https://codefund.io?utm_content=#{impression_details.campaign.id}",
               small_image_url: "https://#{cdn_host}/image.jpg"
             } == payload

      redis_key = impression_details.ip <> "/" <> impression_details.property.id
      assert {:ok, payload |> Poison.encode!()} == Redis.Pool.command(["GET", redis_key])
    end
  end

  describe "create_error_impression/1" do
    test "it creates an error impression for the fallback ad if there are no possible ads for the property",
         %{conn: conn, cdn_host: cdn_host} do
      fallback_campaign =
        insert(:campaign, creative: insert(:creative, small_image_asset: insert(:asset)))

      property =
        insert(:property, audience: insert(:audience, fallback_campaign_id: fallback_campaign.id))

      error_response =
        AdService.Impression.Details.new(conn, property, nil)
        |> AdService.Impression.Details.put_error(:no_possible_ads)
        |> AdService.Impression.Manager.create_error_impression()

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.country == "US"
      assert impression.campaign_id == fallback_campaign.id
      assert impression.house_ad == true
      assert impression.error_code == 2
      assert impression.revenue_amount == Decimal.new("0.000000000000")
      assert impression.distribution_amount == Decimal.new("0.000000000000")

      assert error_response == %{
               description: "This is a Test Creative",
               headline: "Creative Headline",
               house_ad: true,
               large_image_url: "https://#{cdn_host}/image.jpg",
               link: "https://www.example.com/c/#{impression.id}",
               pixel: "//www.example.com/p/#{impression.id}/pixel.png",
               poweredByLink: "https://codefund.io?utm_content=#{fallback_campaign.id}",
               small_image_url: "https://#{cdn_host}/image.jpg"
             }
    end

    test "it creates an error impression if there are no possible ads and no fallback campaign",
         %{conn: conn} do
      property = insert(:property, audience: insert(:audience))

      error_response =
        AdService.Impression.Details.new(conn, property, nil)
        |> AdService.Impression.Details.put_error(:no_possible_ads)
        |> AdService.Impression.Manager.create_error_impression()

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.country == "US"
      assert impression.campaign_id == nil
      refute impression.house_ad
      assert impression.error_code == 2
      assert impression.revenue_amount == Decimal.new("0.000000000000")
      assert impression.distribution_amount == Decimal.new("0.000000000000")

      assert error_response == %{
               pixel: "//www.example.com/p/#{impression.id}/pixel.png",
               poweredByLink: "https://codefund.io?utm_content=",
               description: "",
               headline: "",
               house_ad: false,
               large_image_url: "",
               link: "",
               small_image_url: "",
               reason: "CodeFund does not have an advertiser for you at this time - code: 2"
             }
    end

    test "it creates an error impression for other errors",
         %{conn: conn} do
      property = insert(:property, audience: insert(:audience))

      error_response =
        AdService.Impression.Details.new(conn, property, nil)
        |> AdService.Impression.Details.put_error(:impression_count_exceeded)
        |> AdService.Impression.Manager.create_error_impression()

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.country == "US"
      assert impression.campaign_id == nil
      refute impression.house_ad
      assert impression.error_code == 1
      assert impression.revenue_amount == Decimal.new("0.000000000000")
      assert impression.distribution_amount == Decimal.new("0.000000000000")

      assert error_response == %{
               pixel: "//www.example.com/p/#{impression.id}/pixel.png",
               poweredByLink: "https://codefund.io?utm_content=",
               description: "",
               headline: "",
               large_image_url: "",
               link: "",
               house_ad: false,
               small_image_url: "",
               reason: "CodeFund does not have an advertiser for you at this time - code: 1"
             }
    end
  end
end
