defmodule CodeFundWeb.PropertyController do
  use CodeFundWeb, :controller
  use Framework.CRUDControllerFunctions, ["Property", :all]

  plug(
    CodeFundWeb.Plugs.RequireAnyRole,
    [roles: ["admin", "developer"]] when action not in [:index, :show]
  )
end
