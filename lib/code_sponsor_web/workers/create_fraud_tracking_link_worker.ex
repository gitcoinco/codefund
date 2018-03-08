defmodule CodeSponsorWeb.CreateFraudTrackingLinkWorker do
  alias CodeSponsor.Campaigns

  def perform(campaign_id) do
    campaign = Campaigns.get_campaign!(click_id)

  end
end
