defmodule AdService.Query.ForDisplay do
  import Ecto.Query
  alias AdService.Advertisement
  alias AdService.Query.Shared
  alias CodeFund.Schema.{Campaign, Creative}

  def build(property_filters) do
    from(
      creative in Creative,
      join: campaign in Campaign,
      on: campaign.creative_id == creative.id,
      join: audience in assoc(campaign, :audience)
    )
    |> Shared.build_where_clauses_by_property_filters(property_filters)
    |> where([creative, campaign, ...], campaign.status == 2)
    |> where([creative, campaign, ...], campaign.start_date <= fragment("current_timestamp"))
    |> where([creative, campaign, ...], campaign.end_date >= fragment("current_timestamp"))
    |> select([creative, campaign, _, _], %Advertisement{
      image_url: creative.image_url,
      body: creative.body,
      ecpm: campaign.ecpm,
      campaign_id: campaign.id,
      campaign_name: campaign.name,
      headline: creative.headline
    })
  end
end
