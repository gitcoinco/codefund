defmodule CodeSponsorWeb.UserControllerTest do
  use CodeSponsorWeb.ConnCase
  import CodeSponsor.Factory

  setup do
    normal_user = insert(:user)
    admin_user = insert(:user, %{roles: ["admin"]})

    {:ok, %{normal_user: normal_user, admin_user: admin_user}}
  end

  describe "index" do
    test "it redirects if the user is not an admin", %{conn: conn, normal_user: normal_user} do
      conn = assign conn, :current_user, normal_user

      conn = get conn, user_path(conn, :index)
      assert redirected_to(conn, 302) == "/dashboard"
      assert get_flash(conn, :error) == "You are not authorized to view this page."
    end

    test "lists users if signed in as admin", %{conn: conn, normal_user: normal_user, admin_user: admin_user} do
      conn = assign conn, :current_user, admin_user

      conn = get conn, user_path(conn, :index)
      assert html_response(conn, 200)

      assert conn.assigns.users == [
        normal_user,
        admin_user
      ] |> CodeSponsor.Repo.preload([:properties])
    end
  end

  describe "masquerade" do
    test "it redirects if the user is not an admin", %{conn: conn, normal_user: normal_user} do
      conn = assign conn, :current_user, normal_user

      conn = get conn, user_path(conn, :masquerade, normal_user)
      assert redirected_to(conn, 302) == "/dashboard"
      assert get_flash(conn, :error) == "You are not authorized to view this page."
    end

    test "it allows admin users to masquerade", %{conn: conn, normal_user: normal_user, admin_user: admin_user} do
      conn = assign conn, :current_user, admin_user

      conn = get conn, user_path(conn, :masquerade, normal_user)
      assert redirected_to(conn, 302) == "/dashboard"
      assert get_flash(conn, :notice) == "You have successfully begun masquerading."
      assert Plug.Conn.get_session(conn, "admin_user") == admin_user
    end
  end

  describe "end_masquerade" do
    test "it allows admin users to return to their previous user login", %{conn: conn, admin_user: admin_user} do
      conn = assign conn, :current_user, admin_user

      conn = get conn, user_path(conn, :end_masquerade)
      assert redirected_to(conn, 302) == "/dashboard"
      assert get_flash(conn, :notice) == "You have successfully ended masquerading."
      assert Plug.Conn.get_session(conn, "admin_user") == nil
    end
  end
end
