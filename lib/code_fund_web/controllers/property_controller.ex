defmodule CodeFundWeb.PropertyController do
  use CodeFundWeb, :controller
  use Framework.CRUDControllerFunctions, ["Property", :all]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "developer"])
end
