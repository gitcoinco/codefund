defmodule CodeFundWeb.DashboardController do
  use CodeFundWeb, :controller
  import Joken

  def index(conn, _params) do
    # Build URL for Metabase
    metabase_site_url = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:metabase_site_url]
    secret_key = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:metabase_secret_key]

    metabase_token =
      conn.assigns.current_user
      |> Map.put(:roles, conn.assigns.current_user.roles |> Enum.sort())
      |> Metabase.Helpers.dashboard_map()
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
