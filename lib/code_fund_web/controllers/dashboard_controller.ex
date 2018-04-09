defmodule CodeFundWeb.DashboardController do
  use CodeFundWeb, :controller
  import Joken

  def index(conn, _params) do
    current_user = conn.assigns.current_user

    # Build URL for Metabase
    metabase_site_url = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:metabase_site_url]
    secret_key = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:metabase_secret_key]

    payload =
      cond do
        Enum.member?(current_user.roles, "admin") ->
          %{
            resource: %{dashboard: 1},
            params: %{}
          }

        Enum.member?(current_user.roles, "sponsor") ->
          %{
            resource: %{dashboard: 3},
            params: %{user_id: current_user.id}
          }

        true ->
          %{
            resource: %{dashboard: 2},
            params: %{user_id: current_user.id}
          }
      end

    metabase_token =
      payload
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
