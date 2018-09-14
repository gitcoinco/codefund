defmodule CodeFundWeb.Plugs.RequireAPIAccessTest do
  use CodeFundWeb.ConnCase
  alias CodeFundWeb.Plugs.RequireAPIAccess

  setup do
    conn =
      build_conn() |> Plug.Test.init_test_session(foo: :bar) |> Phoenix.Controller.fetch_flash()

    users = %{
      api_user: insert(:user, %{api_access: true, api_key: "1234567890"}),
      non_api_user: insert(:user, %{api_key: "12345"})
    }

    {:ok, %{conn: conn, users: users}}
  end

  test "return 401 when user doesn't have api access", %{conn: conn, users: users} do
    assert conn
           |> put_req_header("x-codefund-api-key", users.non_api_user.api_key)
           |> RequireAPIAccess.call(nil)
           |> json_response(401) == %{"error" => "You do not have access to the API."}
  end

  test "return 401 when api key is invalid", %{conn: conn} do
    assert conn
           |> put_req_header("x-codefund-api-key", "919191")
           |> RequireAPIAccess.call(nil)
           |> json_response(401) == %{"error" => "You do not have access to the API."}
  end

  test "passed through when api key is valid and user has access", %{conn: conn, users: users} do
    conn =
      conn
      |> put_req_header("x-codefund-api-key", users.api_user.api_key)
      |> RequireAPIAccess.call(nil)

    refute conn.halted
  end
end
