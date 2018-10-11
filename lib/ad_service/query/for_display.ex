defmodule AdService.Query.ForDisplay do
  import Ecto.Query
  alias AdService.UnrenderedAdvertisement
  alias CodeFund.Campaigns
  alias CodeFund.Schema.{Campaign, Creative, Impression, Property}

  def fallback_ad_by_property_id(property_id) do
    from(property in Property,
      join: audience in assoc(property, :audience),
      join: campaign in Campaign,
      on: campaign.id == audience.fallback_campaign_id,
      join: creative in assoc(campaign, :creative),
      join: large_image_asset in assoc(creative, :large_image_asset),
      left_join: small_image_asset in assoc(creative, :small_image_asset),
      left_join: wide_image_asset in assoc(creative, :wide_image_asset),
      where: property.id == ^property_id,
      select: %UnrenderedAdvertisement{
        body: creative.body,
        ecpm: campaign.ecpm,
        campaign_id: campaign.id,
        campaign_name: campaign.name,
        headline: creative.headline,
        images: [
          %AdService.UnprocessedImageAsset{size_descriptor: "small", asset: small_image_asset},
          %AdService.UnprocessedImageAsset{size_descriptor: "large", asset: large_image_asset},
          %AdService.UnprocessedImageAsset{size_descriptor: "wide", asset: wide_image_asset}
        ]
      }
    )
    |> UnrenderedAdvertisement.one()
  end

  def build(%Property{} = property, client_country, ip_address, excluded_advertisers \\ []) do
    from(
      creative in Creative,
      join: campaign in Campaign,
      on: campaign.creative_id == creative.id,
      join: large_image_asset in assoc(creative, :large_image_asset),
      left_join: small_image_asset in assoc(creative, :small_image_asset),
      left_join: wide_image_asset in assoc(creative, :wide_image_asset),
      distinct: campaign.id
    )
    |> where_country_in(client_country)
    |> AdService.Query.TimeManagement.where_accepted_hours_for_ip_address(ip_address)
    |> AdService.Query.TimeManagement.where_not_allowed_on_weekends(ip_address)
    |> with_daily_budget()
    |> where(
      [_creative, campaign, ...],
      fragment(
        "? && ?::varchar[]",
        campaign.included_programming_languages,
        ^property.programming_languages
      )
    )
    |> where(
      [_creative, campaign, ...],
      fragment(
        "? && ?::varchar[] or ? && ?::varchar[]",
        campaign.included_programming_languages,
        ^property.programming_languages,
        campaign.included_topic_categories,
        ^property.topic_categories
      )
    )
    |> where(
      [_creative, campaign, ...],
      fragment(
        "not ? && ?::varchar[] and not ? && ?::varchar[]",
        campaign.excluded_programming_languages,
        ^property.programming_languages,
        campaign.excluded_topic_categories,
        ^property.topic_categories
      )
    )
    |> where(
      [_creative, campaign, ...],
      campaign.id not in ^Campaigns.list_of_ids_for_companies(excluded_advertisers)
    )
    |> where([_creative, campaign, ...], campaign.status == 2)
    |> where([_creative, campaign, ...], campaign.start_date <= fragment("current_timestamp"))
    |> where([_creative, campaign, ...], campaign.end_date >= fragment("current_timestamp"))
    |> AdService.Query.TimeManagement.optionally_exclude_us_hours_only_campaigns()
    |> select(
      [creative, campaign, large_image_asset, small_image_asset, wide_image_asset, ...],
      %UnrenderedAdvertisement{
        body: creative.body,
        ecpm: campaign.ecpm,
        campaign_id: campaign.id,
        campaign_name: campaign.name,
        headline: creative.headline,
        images: [
          %AdService.UnprocessedImageAsset{size_descriptor: "small", asset: small_image_asset},
          %AdService.UnprocessedImageAsset{size_descriptor: "large", asset: large_image_asset},
          %AdService.UnprocessedImageAsset{size_descriptor: "wide", asset: wide_image_asset}
        ]
      }
    )
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
    |> where([_, campaign, ..., sub], sub.daily_spend <= campaign.budget_daily_amount)
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
