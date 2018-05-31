defmodule CodeFundWeb.CampaignController do
  use CodeFundWeb, :controller
  use Framework.Controller
  alias CodeFund.Campaigns
  alias Framework.Phoenix.Form.Helpers, as: FormHelpers
  use Framework.Controller.Stub.Definitions, [:index, :show, :delete]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])

  defconfig do
    [schema: "Campaign"]
  end

  defstub new do
    before_hook(&new_assigns/2)
    |> error(&new_assigns/2)
  end

  defstub edit do
    before_hook(&edit_assigns/2)
  end

  defstub update do
    before_hook(&edit_assigns/2)
  end

  defstub create do
    before_hook(&new_assigns/2)
    |> inject_params(&CodeFundWeb.Hooks.Shared.join_to_user_id/2)
    |> error(&new_assigns/2)
  end

  defp new_assigns(conn, _params) do
    controller_assigns(conn.assigns.current_user)
  end

  defp edit_assigns(_conn, %{"id" => campaign_id}) do
    campaign = Campaigns.get_campaign!(campaign_id)
    controller_assigns(campaign.user)
  end

  defp controller_assigns(user) do
    [
      audiences:
        CodeFund.Audiences.get_by_user(user)
        |> CodeFund.Repo.all()
        |> FormHelpers.repo_objects_to_options(),
      creatives:
        CodeFund.Creatives.by_user(user)
        |> FormHelpers.repo_objects_to_options()
    ]
  end
end
