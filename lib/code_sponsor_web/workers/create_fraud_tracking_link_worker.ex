defmodule CodeSponsorWeb.CreateFraudTrackingLinkWorker do
  alias CodeSponsor.Campaigns

  def perform(campaign_id) do
    campaign =
      CodeSponsor.Campaigns.get_campaign!(campaign_id)
      |> CodeSponsor.Repo.preload(:user)

    redirect_url =
      CodeSponsorWeb.Router.Helpers.track_url(
        CodeSponsorWeb.Endpoint,
        :improvely_inbound,
        campaign_id
      ) |> String.replace(~r/codesponsor\.io\:\d+/, "codesponsor.io")

    payload = %{
      "key"        => System.get_env("IMPROVELY_API_KEY"),
      "project"    => System.get_env("IMPROVELY_PROJECT_ID"),
      "url"        => redirect_url,
      "campaign"   => "#{campaign.id} - #{campaign.name}",
      "source"     => campaign.user.first_name,
      "medium"     => "PPC"
    } |> URI.encode_query

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
      %CodeSponsor.Schema.Campaign{} = campaign  <- body |>Poison.decode!(),
      {:ok, %CodeSponsor.Schema.Campaign{}} <- campaign |> Campaigns.update_campaign(%{fraud_check_url: body["anywhere"]["short_link"]}),
      do: IO.puts("Updated campaign")
    else
      {:error, %{reason: reason}} -> %{"status" => "error", "message" => reason}
      {:error, %Ecto.Changeset{}} ->  IO.puts("Unable to update campaign")
  end
end
