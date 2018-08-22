defmodule AdService.Query.ForDisplay do
  import Ecto.Query
  alias AdService.Advertisement
  alias CodeFund.Campaigns
  alias CodeFund.Schema.{Audience, Campaign, Creative, Impression, Property}

  def fallback_ad_by_property_id(property_id) do
    from(property in Property,
      join: audience in assoc(property, :audience),
      join: campaign in Campaign,
      on: campaign.id == audience.fallback_campaign_id,
      join: creative in assoc(campaign, :creative),
      where: property.id == ^property_id,
      select: %Advertisement{
        image_url: creative.image_url,
        body: creative.body,
        ecpm: campaign.ecpm,
        campaign_id: campaign.id,
        campaign_name: campaign.name,
        headline: creative.headline,
        small_image_object: creative.small_image_object,
        large_image_object: creative.large_image_object
      }
    )
    |> CodeFund.Repo.one()
  end

  def build(%Audience{} = audience, client_country, excluded_advertisers \\ []) do
    from(
      creative in Creative,
      join: campaign in Campaign,
      on: campaign.creative_id == creative.id,
      join: audience in assoc(campaign, :audience),
      distinct: campaign.id
    )
    |> where_country_in(client_country)
    |> with_daily_budget()
    |> where([_creative, campaign, ...], campaign.audience_id == ^audience.id)
    |> where(
      [_creative, campaign, ...],
      campaign.id not in ^Campaigns.list_of_ids_for_companies(excluded_advertisers)
    )
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
      large_image_object: creative.large_image_object
    })
  end

  defp with_daily_budget(query) do
    daily_budget_query =
      from(
        campaign in Campaign,
        left_join: impression in Impression,
        on:
          campaign.id == impression.campaign_id and
            fragment("?::date = now()::date", impression.inserted_at),
        select: %{
          id: campaign.id,
          daily_spend: fragment("COALESCE(SUM(?), 0)", impression.revenue_amount)
        },
        group_by: campaign.id
      )

    query
    |> join(
      :inner,
      [_, campaign, ...],
      sub in subquery(daily_budget_query),
      sub.id == campaign.id
    )
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
