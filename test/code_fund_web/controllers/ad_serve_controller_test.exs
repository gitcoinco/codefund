defmodule CodeFundWeb.AdServeControllerTest do
  use CodeFundWeb.ConnCase

  describe "details" do
    test "serves an ad if property has a sponsorship", %{conn: conn} do
      sponsorship =
        insert(:sponsorship, %{property: insert(:property), creative: insert(:creative)})

      conn = get(conn, ad_serve_path(conn, :details, sponsorship.property))

      assert json_response(conn, 200) == %{
               "title" => "Creative Title",
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
               "title" => "",
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
               "title" => "",
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
               "title" => "",
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
