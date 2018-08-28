defmodule CodeFundWeb.DashboardControllerTest do
  use CodeFundWeb.ConnCase

  describe "index" do
    fn conn, _context ->
      get(conn, theme_path(conn, :index))
    end

    test "renders the index with metabase keys set", %{conn: conn} do
      Application.put_env(:code_fund, Metabase.Helpers,
        metabase_site_url: "http://some.url",
        metabase_secret_key: "JdaDMqC6DEzZP5Mjm9S06nVaLaqExfN3Tyszbywe9c99Sg6RA2h7nRCVB2LFBN1n",
        metabase_dashboard_mappings: [
          admin: "1",
          sponsor: "3",
          user: "2"
        ]
      )

      conn = assign(conn, :current_user, insert(:user))
      conn = get(conn, dashboard_path(conn, :index))

      assert conn.status == 200
      assert conn.assigns.iframe_url =~ "http://some.url"
    end

    test "renders the index with an error when metabase keys unset", %{conn: conn} do
      Application.put_env(:code_fund, Metabase.Helpers, [])
      conn = assign(conn, :current_user, insert(:user))
      conn = get(conn, dashboard_path(conn, :index))

      assert conn.status == 200
      refute conn.assigns.iframe_url

      assert conn |> Phoenix.Controller.get_flash(:error) ==
               "Metabase Secret Key and Site Url must be set to display metabase"
    end
  end
end
