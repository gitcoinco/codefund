defmodule CodeFundWeb.AudienceController do
  use CodeFundWeb, :controller
  use Framework.Controller.Stub.Definitions, [:all]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin"])

  use Framework.Controller

  defconfig do
    [schema: "Audience"]
  end
end
