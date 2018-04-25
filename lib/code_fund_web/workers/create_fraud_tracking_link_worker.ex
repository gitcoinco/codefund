defmodule CodeFundWeb.CreateFraudTrackingLinkWorker do
  alias CodeFund.Campaigns
  import CodeFund.Reporter

  def perform(campaign_id) do
    campaign =
      CodeFund.Campaigns.get_campaign!(campaign_id)
      |> CodeFund.Repo.preload(:user)

    redirect_url =
      CodeFundWeb.Router.Helpers.track_url(
        CodeFundWeb.Endpoint,
        :improvely_inbound,
        campaign_id
      )
      |> String.replace(~r/codesponsor\.io\:\d+/, "codefund.io")
      |> String.replace(~r/codefund\.io\:\d+/, "codefund.io")

    payload =
      %{
        "key" => System.get_env("IMPROVELY_API_KEY"),
        "project" => System.get_env("IMPROVELY_PROJECT_ID"),
        "url" => redirect_url,
        "campaign" => "#{campaign.id} - #{campaign.name}",
        "source" => campaign.user.first_name,
        "medium" => "PPC"
      }
      |> URI.encode_query()

    url = "https://api.improvely.com/v1/link.json"

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Accept", "application/json"}
    ]

    # Example Successful Response:
    #
    #     {
    #       "status": "success",
    #       "google": {
    #         "short_link": "https://codesponsor.iljmp.com/5/bzqjzae?kw={keyword}&device={device}&lp={lpurl}",
    #         "direct_link": "http://localhost:4000/t/r/6e3c1f5b-db0d-47ad-8b47-f1c586974c24?ims=bzqjzae&utm_campaign=6e3c1f5b-db0d-47ad-8b47-f1c586974c24+-+Gitcoin&utm_source=Eric&utm_medium=PPC&utm_term={keyword}"
    #       },
    #       "bing": {
    #         "short_link": "https://codesponsor.iljmp.com/5/bzqjzae?kw={keyword}&device={device}&lp={lpurl}",
    #         "direct_link": "http://localhost:4000/t/r/6e3c1f5b-db0d-47ad-8b47-f1c586974c24?ims=bzqjzae&utm_campaign=6e3c1f5b-db0d-47ad-8b47-f1c586974c24+-+Gitcoin&utm_source=Eric&utm_medium=PPC&utm_term={keyword}"
    #       },
    #       "7search": {
    #         "short_link": "https://codesponsor.iljmp.com/5/bzqjzae?kw=###KEYWORD###",
    #         "direct_link": "http://localhost:4000/t/r/6e3c1f5b-db0d-47ad-8b47-f1c586974c24?ims=bzqjzae&utm_campaign=6e3c1f5b-db0d-47ad-8b47-f1c586974c24+-+Gitcoin&utm_source=Eric&utm_medium=PPC&utm_term=###KEYWORD###"
    #       },
    #       "anywhere": {
    #         "short_link": "https://codesponsor.iljmp.com/5/bzqjzae",
    #         "direct_link": "http://localhost:4000/t/r/6e3c1f5b-db0d-47ad-8b47-f1c586974c24?ims=bzqjzae&utm_campaign=6e3c1f5b-db0d-47ad-8b47-f1c586974c24+-+Gitcoin&utm_source=Eric&utm_medium=PPC"
    #       }
    #     }
    #

    with {:ok, %{status_code: 200, body: body}} <- HTTPoison.post(url, payload, headers),
         %{"anywhere" => %{"short_link" => short_link}} <- body |> Poison.decode!(),
         {:ok, %CodeFund.Schema.Campaign{}} <-
           campaign
           |> Campaigns.update_campaign(%{fraud_check_url: short_link}),
         do: :ok
  else
    :ok ->
      report(:info, "Campaign updated with fraud check url")

    {:error, %{reason: reason}} ->
      report(:warning)
      %{"status" => "error", "message" => reason}

    {:error, %Ecto.Changeset{}} ->
      report(:warning)
      IO.puts("Unable to update campaign")
  end
end
