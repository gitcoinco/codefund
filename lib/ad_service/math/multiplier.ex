defmodule AdService.Math.Multiplier do
  @spec sum([map]) :: integer
  def sum(ad_details) do
    ad_details
    |> Enum.map(&calculate(&1.total_spend, ad_details))
    |> Enum.sum()
  end

  @spec calculate(Decimal.t(), [map]) :: Float.t()
  def calculate(total_spend, ad_details) do
    total_spend_float = total_spend |> Decimal.to_float()
    rate = total_spend_float / AdService.Math.Basic.sum(ad_details)
    weight = AdService.Math.Basic.get_weight(total_spend, ad_details)
    rate * 100 * weight
  end
end
