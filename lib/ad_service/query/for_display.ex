defmodule AdService.Query.ForDisplay do
  import Ecto.Query
  alias AdService.Advertisement
  alias AdService.Query.Shared
  alias CodeFund.Schema.{Audience, Campaign, Creative}

  def build(property_filters) do
    from(
      creative in Creative,
      join: campaign in Campaign,
      on: campaign.creative_id == creative.id,
      join: budgeted_campaign in assoc(campaign, :budgeted_campaign),
      join: insertion_order in assoc(campaign, :insertion_order),
      join: audience in Audience,
      on: insertion_order.audience_id == audience.id,
      where: campaign.status == 2,
      where: budgeted_campaign.day_remain > 0,
      where: budgeted_campaign.total_remain > 0
    )
    |> Shared.build_where_clauses_by_property_filters(property_filters)
    |> select([creative, campaign, _, _], %Advertisement{
      image_url: creative.image_url,
      body: creative.body,
      bid_amount: campaign.bid_amount,
      campaign_id: campaign.id,
      headline: creative.headline
    })
  end
end
