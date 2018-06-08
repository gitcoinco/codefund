defmodule AdService.Math.CPM do
  alias CodeFund.Schema.{Campaign, InsertionOrder, User}

  def revenue_amount(%Campaign{
        total_spend: total_spend,
        insertion_order: %InsertionOrder{impression_count: impression_count}
      }) do
    1 / impression_count * (total_spend |> Decimal.to_float())
  end

  def distribution_amount(%Campaign{} = campaign, %User{
        revenue_rate: revenue_rate
      }) do
    (campaign
     |> revenue_amount) * (revenue_rate |> Decimal.to_float())
  end
end
