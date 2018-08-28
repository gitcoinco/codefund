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
    |> obtain_metabase_credentials_and_render(conn)
  end

  @spec publisher_dashboard(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def publisher_dashboard(conn, _params) do
    fn -> Metabase.Helpers.developer_dashboard_map(conn.assigns.current_user) end
    |> obtain_metabase_credentials_and_render(conn)
  end

  defp obtain_metabase_credentials_and_render(map_function, conn) do
    metabase_credentials = Application.get_env(:code_fund, Metabase.Helpers)

    map_function
    |> render_dashboard(
      conn,
      metabase_credentials[:metabase_secret_key],
      metabase_credentials[:metabase_site_url]
    )
  end

  defp render_dashboard(_, conn, metabase_secret_key, metabase_site_url)
       when is_nil(metabase_secret_key) or is_nil(metabase_site_url) do
    conn
    |> put_flash(:error, "Metabase Secret Key and Site Url must be set to display metabase")
    |> render(
      "index.html",
      iframe_url: nil
    )
  end

  defp render_dashboard(map_function, conn, metabase_secret_key, metabase_site_url) do
    metabase_token =
      map_function.()
      |> token
      |> with_signer(hs256(metabase_secret_key))
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
