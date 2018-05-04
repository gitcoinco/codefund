defmodule CodeFundWeb.TemplateController do
  use CodeFundWeb, :controller
  use Framework.Controller.Stub.Definitions, ["Template", :all]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin"])
end
