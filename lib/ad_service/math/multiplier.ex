defmodule AdService.Math.Multiplier do
  @spec sum([map]) :: integer
  def sum(ad_details) do
    ad_details
    |> Enum.map(&calculate(&1.ecpm, ad_details))
    |> Enum.sum()
  end

  @spec calculate(Decimal.t(), [map]) :: Float.t()
  def calculate(ecpm, ad_details) do
    ecpm_float = ecpm |> Decimal.to_float()
    rate = ecpm_float / AdService.Math.Basic.sum(ad_details)
    weight = AdService.Math.Basic.get_weight(ecpm, ad_details)
    rate * 100 * weight
  end
end
