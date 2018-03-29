defmodule CodeFundWeb.UserController do
  use CodeFundWeb, :controller
  import Ecto.Query
  alias CodeFund.Repo
  alias CodeFund.Schema.User

  plug(CodeFundWeb.Plugs.RequireAnyRole, [roles: ["admin"]] when action in [:index, :masquerade])
  use Coherence.Config

  def index(conn, _params) do
    render(
      conn,
      "index.html",
      users: Repo.all(from(u in User, preload: [:properties], order_by: u.first_name))
    )
  end

  def masquerade(conn, %{"id" => user_id}) do
    Repo.get(User, user_id)
    |> handle_masquerade(conn)
    |> put_session("admin_user", conn.assigns.current_user)
    |> put_flash(:notice, "You have successfully begun masquerading.")
    |> redirect(to: dashboard_path(conn, :index))
  end

  def end_masquerade(conn, _params) do
    conn
    |> get_session("admin_user")
    |> handle_masquerade(conn)
    |> delete_session("admin_user")
    |> put_flash(:notice, "You have successfully ended masquerading.")
    |> redirect(to: dashboard_path(conn, :index))
  end

  defp handle_masquerade(user, conn) do
    Config.auth_module()
    |> apply(Config.create_login(), [conn, user, [id_key: Config.schema_key()]])
  end
end
