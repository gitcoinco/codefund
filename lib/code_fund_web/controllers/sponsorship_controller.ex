defmodule CodeFundWeb.SponsorshipController do
  use CodeFundWeb, :controller

  use Framework.CRUDControllerFunctions, ["Sponsorship", :all]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])
end
