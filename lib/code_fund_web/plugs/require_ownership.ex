defmodule CodeFundWeb.Plugs.RequireOwnership do
  import Plug.Conn
  import Ecto.Query
  import CodeFund.Reporter
  alias CodeFund.Users

  def init(opts), do: opts

  def call(conn, opts) do
    opts =
      Keyword.merge(
        [
          roles: [],
          to: "/dashboard",
          flash: "You are not authorized to view this page."
        ],
        opts
      )

    [object_type, id | _tail] = conn.path_info

    object_type =
      Module.concat([
        CodeFund,
        Schema,
        "#{object_type |> String.capitalize() |> Inflex.singularize()}"
      ])

    with %CodeFund.Schema.User{} = user <- conn.assigns[:current_user],
         %{} = object <- from(o in object_type, where: o.id == ^id) |> CodeFund.Repo.one(),
         true <-
           Users.has_role?(user.roles, opts[:roles]) || user.id == (object.id || object.user_id) do
      conn
    else
      _ ->
        report(:error)

        conn
        |> Phoenix.Controller.redirect(to: opts[:to])
        |> Phoenix.Controller.put_flash(:error, opts[:flash])
        |> halt
    end
  end
end
