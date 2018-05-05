defmodule CodeFundWeb.CreativeController do
  use CodeFundWeb, :controller
  use Framework.Controller
  use Framework.Controller.Stub.Definitions, [:all, except: [:create]]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])

  defconfig do
    [schema: "Creative"]
  end

  defstub create do
    inject_params(&CodeFundWeb.Hooks.Shared.join_to_user_id/2)
  end
end
