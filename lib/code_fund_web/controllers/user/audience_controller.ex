defmodule CodeFundWeb.User.AudienceController do
  use CodeFundWeb, :controller
  use Framework.Controller.Stub.Definitions, [:index, :show]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])

  plug(
    CodeFundWeb.Plugs.RequireOwnership,
    [roles: ["admin"]] when action in [:update, :edit, :create, :delete]
  )

  use Framework.Controller

  defconfig do
    [schema: "Audience", nested: ["User"]]
  end

  defstub new do
    before_hook(&create_assigns_list/2)
  end

  defstub edit do
    before_hook(&update_assigns_list/2)
  end

  defstub create do
    before_hook(&create_assigns_list/2)
    |> inject_params(&CodeFundWeb.Hooks.Shared.join_to_user_id/2)
    |> error(&create_assigns_list/2)
  end

  defstub update do
    before_hook(&update_assigns_list/2)
    |> error(&update_assigns_list/2)
  end

  defstub delete do
    before_hook(&create_assigns_list/2)
  end

  defp create_assigns_list(_conn, %{
         "user_id" => user_id
       }) do
    [
      action: :create,
      associations: [user_id]
    ]
  end

  defp update_assigns_list(_conn, %{
         "user_id" => user_id
       }) do
    [
      action: :update,
      associations: [user_id]
    ]
  end
end
