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
      join: audience in assoc(campaign, :audience),
      where: campaign.status == 2,
      where: campaign.start_date <= fragment("current_timestamp"),
      where: campaign.end_date >= fragment("current_timestamp")
    )
    |> Shared.build_where_clauses_by_property_filters(property_filters)
    |> select([creative, campaign, _, _], %Advertisement{
      image_url: creative.image_url,
      body: creative.body,
      total_spend: campaign.total_spend,
      campaign_id: campaign.id,
      headline: creative.headline
    })
  end
end
