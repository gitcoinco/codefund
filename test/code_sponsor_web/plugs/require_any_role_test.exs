defmodule CodeSponsorWeb.Plugs.RequireAnyRoleTest do
  use CodeSponsorWeb.ConnCase
  alias CodeSponsorWeb.Plugs.RequireAnyRole
  alias CodeSponsor.Schema.User

  test "user is redirected when current_user is not assigned" do
    conn = build_conn() |> require_login

    assert redirected_to(conn) == "/dashboard"
  end

  test "user is redirected when current_user does not have the role of admin" do
    conn = build_conn() |> authenticate_as_developer |> require_login

    assert redirected_to(conn) == "/dashboard"
  end

  test "user passes through when current_user is assigned and is an admin" do
    conn = build_conn() |> authenticate_as_admin |> require_login

    assert not_redirected?(conn)
  end

  defp require_login(conn) do
    conn |> RequireAnyRole.call(%{roles: ["admin"], to: "/dashboard"})
  end

  defp authenticate_as_developer(conn) do
    conn |> assign(:current_user, %User{roles: ["developer"]})
  end

  defp authenticate_as_admin(conn) do
    conn |> assign(:current_user, %User{roles: ["admin"]})
  end

  defp not_redirected?(conn) do
    conn.status != 302
  end
end