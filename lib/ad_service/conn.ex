defmodule AdService.Conn do
  @spec set_user_agent_header(Plug.Conn.t(), nil | String.t()) :: Plug.Conn.t()
  def set_user_agent_header(conn, nil), do: set_user_agent_header(conn, "")

  def set_user_agent_header(conn, user_agent) do
    case conn |> Plug.Conn.get_req_header("user-agent") do
      [] -> conn |> Plug.Conn.put_req_header("user-agent", user_agent)
      _ -> conn
    end
  end

  @spec set_ip_address(Plug.Conn.t(), nil | String.t()) :: Plug.Conn.t()
  def set_ip_address(conn, nil), do: conn

  def set_ip_address(conn, ip_address) do
    ip_address =
      ip_address
      |> String.split(".")
      |> Enum.map(&String.to_integer(&1))
      |> List.to_tuple()

    conn
    |> Plug.Conn.put_private(:server_ip, conn.remote_ip)
    |> Map.put(:remote_ip, ip_address)
  end
end
