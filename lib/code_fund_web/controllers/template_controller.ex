defmodule CodeFundWeb.TemplateController do
  use CodeFundWeb, :controller
  use Framework.CRUDControllerFunctions, ["Template", :all]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin"])
end
