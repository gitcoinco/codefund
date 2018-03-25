defmodule CodeSponsorWeb.PropertyControllerTest do
  use CodeSponsorWeb.ConnCase

  describe "PropertyController" do
    test "index/0", %{conn: conn} do
      user = insert(:user, %{roles: ["developer"]})
      insert_list(25, :property, user: user)
      conn = assign conn, :current_user, user

      conn = get conn, property_path(conn, :index)
      assert html_response(conn, 200)
    end

    test "index/0 redirects unauth user", %{conn: conn} do
      user = insert(:user)
      conn = assign conn, :current_user, user
      conn = get conn, property_path(conn, :index)
      assert html_response(conn, 302)
    end

    test "new/2", %{conn: conn} do
      user = insert(:user, %{roles: ["developer"]})
      conn = assign conn, :current_user, user

      conn = get conn, property_path(conn, :new)
      assert html_response(conn, 200)
    end

  end
end
