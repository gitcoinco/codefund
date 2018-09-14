defmodule CodeFundWeb.Plugs.RequireAPIAccess do
  import Plug.Conn
  import Phoenix.Controller
  alias CodeFund.Users
  alias CodeFund.Schema.User

  def init(_), do: []

  def call(conn, _) do
    conn
    |> get_req_header("x-codefund-api-key")
    |> check_permissions(conn)
  end

  defp check_permissions([], conn) do
    error_response(conn, "An API Key (x-codefund-api-key header) is required.")
  end

  defp check_permissions([api_key], conn) when is_binary(api_key) do
    case Users.get_by_api_key(api_key) do
      %User{api_access: true} -> conn
      _ -> error_response(conn)
    end
  end

  defp error_response(conn, message \\ "You do not have access to the API.") do
    conn
    |> put_status(401)
    |> json(%{error: message})
    |> halt
  end
end
