defmodule CodeFundWeb.AdServeControllerTest do
  use CodeFundWeb.ConnCase
  import CodeFund.Factory

  setup do
    property = insert(:property)
    theme = insert(:theme, slug: "light", template: insert(:template, slug: "default"))
    {:ok, %{property: property, theme: theme}}
  end

  describe "embed" do
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
    test "serves an ad if property has a campaign and creates an impression", %{conn: conn} do
      creative = insert(:creative)
      property = insert(:property, programming_languages: ["C", "JavaScript"])
      audience = insert(:audience, %{programming_languages: ["Ruby", "C"]})

      insert(:audience, %{programming_languages: ["Java", "Rust"]})
      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0

      campaign =
        insert(
          :campaign,
          status: 2,
          bid_amount: Decimal.new(1),
          budget_daily_amount: Decimal.new(1),
          budget_monthly_amount: Decimal.new(1),
          budget_total_amount: Decimal.new(1),
          creative: creative,
          audience: audience
        )

      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})
      conn = get(conn, ad_serve_path(conn, :details, property))

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.campaign_id == campaign.id

      assert json_response(conn, 200) == %{
               "headline" => "Creative Headline",
               "description" => "This is a Test Creative",
               "image" => "http://example.com/some.png",
               "link" => "https://www.example.com/c/#{impression.id}",
               "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=#{campaign.id}"
             }
    end

    test "returns an error if property does not have a campaign but still creates an impression",
         %{conn: conn} do
      creative = insert(:creative)
      property = insert(:property, programming_languages: ["C++", "JavaScript"])
      audience = insert(:audience, %{programming_languages: ["Ruby", "C"]})

      insert(:audience, %{programming_languages: ["Java", "Rust"]})
      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0

      insert(
        :campaign,
        status: 2,
        bid_amount: Decimal.new(1),
        budget_daily_amount: Decimal.new(1),
        budget_monthly_amount: Decimal.new(1),
        budget_total_amount: Decimal.new(1),
        creative: creative,
        audience: audience
      )

      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})
      conn = get(conn, ad_serve_path(conn, :details, property))

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.campaign_id == nil

      assert json_response(conn, 200) == %{
               "headline" => "",
               "description" => "",
               "image" => "",
               "link" => "",
               "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=",
               "reason" => "CodeFund does not have an advertiser for you at this time"
             }
    end

    test "returns an error if property is not active but still creates an impressoin", %{
      conn: conn
    } do
      property = insert(:property, %{status: 0})
      conn = conn |> Map.put(:remote_ip, {12, 109, 12, 14})
      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0
      conn = get(conn, ad_serve_path(conn, :details, property))

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "12.109.12.14"
      assert impression.property_id == property.id
      assert impression.campaign_id == nil

      assert json_response(conn, 200) == %{
               "headline" => "",
               "description" => "",
               "image" => "",
               "link" => "",
               "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=",
               "reason" => "This property is not currently active"
             }
    end

    test "returns an error if viewer is from a blocked country but still creates an impression",
         %{conn: conn} do
      property = insert(:property)
      conn = conn |> Map.put(:remote_ip, {163, 177, 112, 32})

      assert CodeFund.Impressions.list_impressions() |> Enum.count() == 0
      conn = get(conn, ad_serve_path(conn, :details, property))

      impression = CodeFund.Impressions.list_impressions() |> List.first()
      assert impression.ip == "163.177.112.32"

      assert impression.property_id == property.id
      assert impression.campaign_id == nil

      assert json_response(conn, 200) == %{
               "headline" => "",
               "description" => "",
               "image" => "",
               "link" => "",
               "pixel" => "//www.example.com/p/#{impression.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=",
               "reason" => "CodeFund does not have an advertiser for you at this time"
             }
    end
  end
end
