defmodule CodeFundWeb.DashboardController do
  use CodeFundWeb, :controller
  import Joken

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    fn ->
      conn.assigns.current_user
      |> Map.put(:roles, conn.assigns.current_user.roles |> Enum.sort())
      |> Metabase.Helpers.dashboard_map()
    end
    |> metabase_render(conn)
  end

  @spec publisher_dashboard(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def publisher_dashboard(conn, _params) do
    fn -> Metabase.Helpers.developer_dashboard_map(conn.assigns.current_user) end
    |> metabase_render(conn)
  end

  defp metabase_render(map_function, conn) do
    metabase_site_url = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:metabase_site_url]
    secret_key = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:metabase_secret_key]

    metabase_token =
      map_function.()
      |> token
      |> with_signer(hs256(secret_key))
      |> sign
      |> get_compact

    iframe_url =
      "#{metabase_site_url}/embed/dashboard/#{metabase_token}#bordered=false&titled=true"

    render(
      conn,
      "index.html",
      iframe_url: iframe_url
    )
  end
end
