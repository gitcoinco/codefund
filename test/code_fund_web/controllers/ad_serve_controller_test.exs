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
    test "serves an ad if property has a sponsorship", %{conn: conn} do
      sponsorship =
        insert(:sponsorship, %{property: insert(:property), creative: insert(:creative)})

      conn = get(conn, ad_serve_path(conn, :details, sponsorship.property))

      assert json_response(conn, 200) == %{
               "headline" => "Creative Headline",
               "description" => "This is a Test Creative",
               "image" => "http://example.com/some.png",
               "link" => "https://www.example.com/t/s/#{sponsorship.id}",
               "pixel" => "//www.example.com/t/p/#{sponsorship.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=#{sponsorship.id}"
             }
    end

    test "returns an error if property does not have a sponsorship", %{conn: conn} do
      property = insert(:property)

      conn = get(conn, ad_serve_path(conn, :details, property))

      assert json_response(conn, 200) == %{
               "headline" => "",
               "description" => "",
               "image" => "",
               "link" => "",
               "pixel" => "//www.example.com/t/l/#{property.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=",
               "reason" => "CodeFund does not have an advertiser for you at this time"
             }
    end

    test "returns an error if a sponsored property has no creative", %{conn: conn} do
      sponsorship = insert(:sponsorship, %{property: insert(:property), creative: nil})

      conn = get(conn, ad_serve_path(conn, :details, sponsorship.property))

      assert json_response(conn, 200) == %{
               "headline" => "",
               "description" => "",
               "image" => "",
               "link" => "",
               "pixel" => "//www.example.com/t/l/#{sponsorship.property.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=",
               "reason" => "CodeFund creative has not been assigned to the sponsorship"
             }
    end

    test "returns an error if property is not active", %{conn: conn} do
      property = insert(:property, %{status: 0})

      conn = get(conn, ad_serve_path(conn, :details, property))

      assert json_response(conn, 200) == %{
               "headline" => "",
               "description" => "",
               "image" => "",
               "link" => "",
               "pixel" => "//www.example.com/t/l/#{property.id}/pixel.png",
               "poweredByLink" => "https://codefund.io?utm_content=",
               "reason" => "This property is not currently active"
             }
    end
  end
end
