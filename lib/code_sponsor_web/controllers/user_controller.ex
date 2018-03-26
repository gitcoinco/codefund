defmodule CodeSponsorWeb.UserController do
  use CodeSponsorWeb, :controller
  import Ecto.Query
  alias CodeSponsor.Repo
  alias CodeSponsor.Schema.User

  plug CodeSponsorWeb.Plugs.RequireAnyRole, [roles: ["admin"]]

  def index(conn, _params) do
    render conn, "index.html", users: Repo.all from u in User, preload: [:properties]
  end
end
