defmodule AdService.Query.ForDisplay do
  import Ecto.Query
  alias AdService.Advertisement
  alias AdService.Query.Shared
  alias CodeFund.Campaigns
  alias CodeFund.Schema.{Audience, Campaign, Creative, Impression}

  def build(%Audience{} = audience, client_country, excluded_advertisers \\ []) do
    fn query ->
      query
      |> where_country_in(client_country)
      |> with_daily_budget()
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
    |> select([creative, campaign, ...], %Advertisement{
      image_url: creative.image_url,
      body: creative.body,
      ecpm: campaign.ecpm,
      campaign_id: campaign.id,
      campaign_name: campaign.name,
      headline: creative.headline,
      small_image_object: creative.small_image_object,
      small_image_bucket: creative.small_image_bucket,
      large_image_object: creative.large_image_object,
      large_image_bucket: creative.large_image_bucket
    })
  end

  defp with_daily_budget(query) do
    daily_budget_query =
      from(
        campaign in Campaign,
        left_join: impression in Impression,
        on: campaign.id == impression.campaign_id,
        where: fragment("?::date = now()::date", impression.inserted_at),
        select: %{daily_spend: fragment("COALESCE(SUM(?), 0)", impression.revenue_amount)}
      )

    query
    |> join(:inner_lateral, [...], sub in subquery(daily_budget_query))
    |> where([_, campaign, _, sub], sub.daily_spend <= campaign.budget_daily_amount)
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
