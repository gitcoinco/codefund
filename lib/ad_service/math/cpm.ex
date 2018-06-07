defmodule AdService.Math.CPM do
  def revenue_amount(%CodeFund.Schema.Campaign{bid_amount: bid_amount}) do
    (bid_amount |> Decimal.to_float()) / 1000
  end

  def distribution_amount(%CodeFund.Schema.Campaign{} = campaign, %CodeFund.Schema.User{
        revenue_rate: revenue_rate
      }) do
    (campaign
     |> revenue_amount) * (revenue_rate |> Decimal.to_float())
  end
end
