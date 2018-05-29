defmodule AdService.Math.Multiplier do
  @spec sum([map]) :: integer
  def sum(ad_details) do
    ad_details
    |> Enum.map(&calculate(&1.bid_amount, ad_details))
    |> Enum.sum()
  end

  @spec calculate(Decimal.t(), [map]) :: Float.t()
  def calculate(bid_amount, ad_details) do
    bid_amount_float = bid_amount |> Decimal.to_float()
    rate = bid_amount_float / AdService.Math.Basic.sum(ad_details)
    weight = AdService.Math.Basic.get_weight(bid_amount, ad_details)
    rate * 100 * weight
  end
end
