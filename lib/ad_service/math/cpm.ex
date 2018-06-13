defmodule AdService.Math.CPM do
  alias CodeFund.Schema.{Campaign, User}

  def revenue_amount(%Campaign{ecpm: ecpm}) do
    (ecpm |> Decimal.to_float()) / 1000
  end

  def distribution_amount(%Campaign{} = campaign, %User{
        revenue_rate: revenue_rate
      }) do
    (campaign
     |> revenue_amount) * (revenue_rate |> Decimal.to_float())
  end
end
