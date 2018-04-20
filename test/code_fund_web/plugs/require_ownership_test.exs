defmodule CodeFundWeb.Plugs.RequireOwnershipTest do
  use CodeFundWeb.ConnCase
  alias CodeFundWeb.Plugs.RequireOwnership
  alias CodeFund.Schema.User

  setup do
    conn =
      build_conn() |> Plug.Test.init_test_session(foo: :bar) |> Phoenix.Controller.fetch_flash()

    {:ok, %{conn: conn}}
  end

  test "user passes through when current_user is assigned and is an admin", %{conn: conn} do
    conn = conn |> Map.merge(%{path_info: ["users", insert(:user).id]})

    assert conn
           |> authenticate_as_roles(["admin"])
           |> require_ownership_unless_roles(["admin"])
           |> Map.get(:halted) == false
  end

  test "user passes through when current_user does not have roles but owns the object", %{
    conn: conn
  } do
    user = insert(:user)
    conn = conn |> Map.merge(%{path_info: ["users", user.id]})

    assert conn
           |> authenticate_as_id_with_roles(user.id, ["developer"])
           |> require_ownership_unless_roles(["admin"])
           |> Map.get(:halted) == false
  end

  test "user is halted when current_user does not have roles and does not owns the object", %{
    conn: conn
  } do
    user = insert(:user)
    conn = conn |> Map.merge(%{path_info: ["users", insert(:user).id]})

    assert conn
           |> authenticate_as_id_with_roles(user.id, ["developer"])
           |> require_ownership_unless_roles(["admin"])
           |> Map.get(:halted) == true
  end

  defp require_ownership_unless_roles(conn, roles) when is_list(roles) do
    conn |> RequireOwnership.call(roles: roles)
  end

  defp authenticate_as_id_with_roles(conn, id, roles) when is_list(roles) do
    conn |> assign(:current_user, %User{id: id, roles: roles})
  end

  defp authenticate_as_roles(conn, roles) when is_list(roles) do
    conn |> assign(:current_user, %User{roles: roles})
  end
end
