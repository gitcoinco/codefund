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
    before_hook(&get_audiences/2)
    |> error(&get_audiences/2)
  end

  defstub edit do
    before_hook(&get_audiences/2)
    |> error(&get_audiences/2)
  end

  defstub update do
    before_hook(&get_audiences/2)
    |> error(&get_audiences/2)
  end

  defstub create do
    before_hook(&get_audiences/2)
    |> inject_params(&CodeFundWeb.Hooks.Shared.join_to_user_id/2)
    |> error(&get_audiences/2)
  end

  def generate_fraud_check_url(conn, %{"id" => id}) do
    campaign = Campaigns.get_campaign!(id)

    Exq.enqueue(Exq, "cs_high", CodeFundWeb.CreateFraudTrackingLinkWorker, [campaign.id])

    conn
    |> put_flash(:info, "Fraud Check URL is being generated")
    |> redirect(to: campaign_path(conn, :show, campaign))
  end

  defp get_audiences(conn, _params) do
    [
      audiences:
        CodeFund.Audiences.get_by_user(conn.assigns.current_user)
        |> CodeFund.Repo.all()
        |> FormHelpers.repo_objects_to_options()
    ]
  end
end
