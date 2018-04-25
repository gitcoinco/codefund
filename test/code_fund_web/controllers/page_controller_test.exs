defmodule CodeFundWeb.PageControllerTest do
  use CodeFundWeb.ConnCase

  describe "GET index" do
    test "renders the home page", %{conn: conn} do
      conn = get(conn, page_path(conn, :index))

      assert html_response(conn, 200) =~ "Connect with software developers"
      assert conn.private.phoenix_layout == false
    end
  end

  describe "GET contact" do
    test "renders the advertiser contact form", %{conn: conn} do
      conn = get(conn, page_path(conn, :contact, :advertiser))

      assert html_response(conn, 200) =~ "Advertise with CodeFund"
    end

    test "renders the publisher contact form", %{conn: conn} do
      conn = get(conn, page_path(conn, :contact, :publisher))

      assert html_response(conn, 200) =~ "Become a Publisher"
    end

    test "redirects to home page if called with an invalid key", %{conn: conn} do
      conn = get(conn, page_path(conn, :contact, :narf))
      assert redirected_to(conn, 302) == page_path(conn, :index)
    end
  end

  describe "POST contact" do
    test "successfully posts the advertiser contact form", %{conn: conn} do
      conn =
        post(
          conn,
          page_path(conn, :contact, :advertiser, %{
            form: %{first_name: "hi", last_name: "hi", email: "hi@example.com"}
          })
        )

      assert redirected_to(conn, 302) == page_path(conn, :index)

      assert conn |> Phoenix.Controller.get_flash(:info) ==
               "Your request was submitted successfully"
    end

    test "successfully posts the publisher contact form", %{conn: conn} do
      conn =
        post(
          conn,
          page_path(conn, :contact, :publisher, %{
            form: %{first_name: "hi", last_name: "hi", email: "hi@example.com"}
          })
        )

      assert redirected_to(conn, 302) == page_path(conn, :index)

      assert conn |> Phoenix.Controller.get_flash(:info) ==
               "Your request was submitted successfully"
    end

    test "redirects to home page if called with an invalid key", %{conn: conn} do
      conn = get(conn, page_path(conn, :contact, :narf))
      assert redirected_to(conn, 302) == page_path(conn, :index)
      assert conn |> Phoenix.Controller.get_flash(:info) == nil
    end
  end
end
