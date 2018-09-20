defmodule AdService.ConnTest do
  use CodeFundWeb.ConnCase

  setup do
    {:ok, %{conn: build_conn()}}
  end

  describe "set_user_agent_header/2" do
    test "it sets empty string if the conn doesn't have a user_agent and is passed nil", %{
      conn: conn
    } do
      conn = AdService.Conn.set_user_agent_header(conn, nil)
      assert conn |> Plug.Conn.get_req_header("user-agent") == [""]
    end

    test "it leaves the user agent alone if the conn has a user_agent and is passed nil", %{
      conn: conn
    } do
      conn =
        conn
        |> Plug.Conn.put_req_header("user-agent", "some user agent")
        |> AdService.Conn.set_user_agent_header(nil)

      assert conn |> Plug.Conn.get_req_header("user-agent") == ["some user agent"]
    end

    test "it sets user agent if the conn doesn't have a user_agent and is passed one", %{
      conn: conn
    } do
      conn = AdService.Conn.set_user_agent_header(conn, "some user agent")
      assert conn |> Plug.Conn.get_req_header("user-agent") == ["some user agent"]
    end

    test "it leaves the user agent alone if the conn has a user_agent and is passed one", %{
      conn: conn
    } do
      conn =
        conn
        |> Plug.Conn.put_req_header("user-agent", "some user agent")
        |> AdService.Conn.set_user_agent_header("another user agent")

      assert conn |> Plug.Conn.get_req_header("user-agent") == ["some user agent"]
    end
  end
end
