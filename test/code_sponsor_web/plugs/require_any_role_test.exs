defmodule CodeSponsorWeb.Plugs.RequireAnyRoleTest do
  use CodeSponsorWeb.ConnCase
  alias CodeSponsorWeb.Plugs.RequireAnyRole
  alias CodeSponsor.Schema.User

  setup do
    conn = build_conn() |> Plug.Test.init_test_session([foo: :bar]) |> Phoenix.Controller.fetch_flash
    {:ok, %{conn: conn}}
  end

  test "user is redirected when current_user is not assigned", %{conn: conn} do
    assert conn
    |> require_login
    |> redirected_to() == "/dashboard"
  end

  test "user is redirected when current_user does not have the role of admin", %{conn: conn} do
    assert conn
    |> authenticate_as_roles(["developer"])
    |> require_login
    |> redirected_to() == "/dashboard"
  end

  test "user passes through when current_user is assigned and is an admin", %{conn: conn} do
    refute conn
    |> authenticate_as_roles(["admin"])
    |> require_login
    |> Map.get(:status) == 302
  end

  defp require_login(conn) do
    conn |> RequireAnyRole.call([roles: ["admin"]])
  end

  defp authenticate_as_roles(conn, roles) when is_list(roles) do
    conn |> assign(:current_user, %User{roles: roles})
  end
end