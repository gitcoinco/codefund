defmodule AdService.Query.ForDisplay do
  import Ecto.Query
  alias AdService.Advertisement
  alias AdService.Query.Shared
  alias CodeFund.Campaigns
  alias CodeFund.Schema.{Audience, Campaign, Creative}

  def build(%Audience{} = audience, client_country, excluded_advertisers \\ []) do
    fn query ->
      query
      |> where_country_in(client_country)
      |> where([_creative, campaign, ...], campaign.audience_id == ^audience.id)
      |> where(
        [_creative, campaign, ...],
        campaign.id not in ^Campaigns.list_of_ids_for_companies(excluded_advertisers)
      )
    end
    |> core_query()
  end

  def build(property_filters) do
    fn query ->
      query
      |> Shared.build_where_clauses_by_property_filters(property_filters)
    end
    |> core_query()
  end

  defp core_query(specialized_function) do
    from(
      creative in Creative,
      join: campaign in Campaign,
      on: campaign.creative_id == creative.id,
      join: audience in assoc(campaign, :audience)
    )
    |> specialized_function.()
    |> where([_creative, campaign, ...], campaign.status == 2)
    |> where([_creative, campaign, ...], campaign.start_date <= fragment("current_timestamp"))
    |> where([_creative, campaign, ...], campaign.end_date >= fragment("current_timestamp"))
    |> select([creative, campaign, _, _], %Advertisement{
      image_url: creative.image_url,
      body: creative.body,
      ecpm: campaign.ecpm,
      campaign_id: campaign.id,
      campaign_name: campaign.name,
      headline: creative.headline
    })
  end

  defp where_country_in(query, nil), do: query

  defp where_country_in(query, client_country) do
    query
    |> where(
      [_creative, campaign, ...],
      ^client_country in campaign.included_countries
    )
  end
end
