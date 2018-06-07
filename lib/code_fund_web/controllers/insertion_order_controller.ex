defmodule CodeFundWeb.InsertionOrderController do
  use CodeFundWeb, :controller
  use Framework.Controller
  alias Framework.Phoenix.Form.Helpers, as: FormHelpers
  use Framework.Controller.Stub.Definitions, [:all, except: [:new, :edit, :create, :update]]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin"])

  defconfig do
    [schema: "InsertionOrder"]
  end

  defstub new do
    before_hook(&controller_assigns/2)
    |> error(&controller_assigns/2)
  end

  defstub edit do
    before_hook(&controller_assigns/2)
  end

  defstub update do
    before_hook(&controller_assigns/2)
  end

  defstub create do
    before_hook(&controller_assigns/2)
    |> error(&controller_assigns/2)
  end

  defp controller_assigns(_conn, _params) do
    [
      audience_choices:
        CodeFund.Audiences.list_audiences()
        |> FormHelpers.repo_objects_to_options(),
      advertiser_choices:
        CodeFund.Users.get_by_role("sponsor")
        |> FormHelpers.repo_objects_to_options([:first_name, :last_name], " ")
    ]
  end
end
