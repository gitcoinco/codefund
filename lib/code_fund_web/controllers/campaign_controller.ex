defmodule CodeFundWeb.CampaignController do
  use CodeFundWeb, :controller

  alias CodeFund.Campaigns

  use Framework.CRUDControllerFunctions, ["Campaign", :all]

  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])

  def generate_fraud_check_url(conn, %{"id" => id}) do
    campaign = Campaigns.get_campaign!(id)

    Exq.enqueue(Exq, "cs_high", CodeFundWeb.CreateFraudTrackingLinkWorker, [campaign.id])

    conn
    |> put_flash(:info, "Fraud Check URL is being generated")
    |> redirect(to: campaign_path(conn, :show, campaign))
  end
end
