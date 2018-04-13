defmodule CodeFundWeb.CreativeController do
  use CodeFundWeb, :controller
  use Framework.CRUDControllerFunctions, ["Creative", :all]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])
end
