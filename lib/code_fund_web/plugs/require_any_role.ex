defmodule CodeFundWeb.Plugs.RequireAnyRole do
  import Plug.Conn
  import CodeFund.Reporter
  alias CodeFund.Users

  def init(opts), do: opts

  def call(conn, opts) do
    opts =
      Keyword.merge(
        [
          roles: ["developer"],
          to: "/dashboard",
          flash: "You are not authorized to view this page."
        ],
        opts
      )

    with %CodeFund.Schema.User{} = user <- conn.assigns[:current_user],
         true <- Users.has_role?(user.roles, opts[:roles]) do
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
