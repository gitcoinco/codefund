defmodule CodeFundWeb.CreativeController do
  use CodeFundWeb, :controller
  use Framework.Controller
  use Framework.Controller.Stub.Definitions, ["Creative", :all, except: [:create]]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])

  defstub create("Creative") do
    inject_params(&CodeFundWeb.Hooks.Shared.join_to_user_id/2)
  end
end
