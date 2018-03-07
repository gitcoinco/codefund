defmodule CodeSponsorWeb.Plugs.RequireAnyRole do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, %{roles: roles, to: url}) do
    if conn.assigns[:current_user] do
      current_roles = conn.assigns[:current_user].roles
      matches = all_matches(current_roles, roles)
      if Enum.empty?(matches) do
        conn |> Phoenix.Controller.redirect(to: url) |> halt
      else
        conn
      end
    else
      conn |> Phoenix.Controller.redirect(to: url) |> halt
    end
  end

  defp all_matches(existing_roles, target_roles) do
    Enum.filter(existing_roles, fn(role) ->
      Enum.member?(target_roles, role)
    end)
  end
end