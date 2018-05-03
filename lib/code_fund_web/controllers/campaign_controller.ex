defmodule CodeFundWeb.CampaignController do
  use CodeFundWeb, :controller
  use Framework.Controller
  alias CodeFund.Campaigns
  use Framework.Controller.Stub.Definitions, ["Campaign", :all, except: [:create]]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])

  defstub create("Campaign") do
    inject_params(&CodeFundWeb.Hooks.Shared.join_to_user_id/2)
  end

  def generate_fraud_check_url(conn, %{"id" => id}) do
    campaign = Campaigns.get_campaign!(id)

    Exq.enqueue(Exq, "cs_high", CodeFundWeb.CreateFraudTrackingLinkWorker, [campaign.id])

    conn
    |> put_flash(:info, "Fraud Check URL is being generated")
    |> redirect(to: campaign_path(conn, :show, campaign))
  end
end
