defmodule AdService.Math.Basic do
  @spec get_all_display_rates([%AdService.Advertisement{}]) :: [map]
  def get_all_display_rates(ad_details) do
    ad_details
    |> Enum.map(&display_rate(&1, ad_details))
    |> Enum.sort(&(&1.display_rate > &2.display_rate))
  end

  @spec sum([%AdService.Advertisement{}]) :: Float.t()
  def sum(advertisements) do
    advertisements
    |> Enum.map(&(&1.ecpm |> Decimal.to_float()))
    |> Enum.sum()
  end

  @spec get_weight(Decimal.t(), [%AdService.Advertisement{}]) :: integer
  def get_weight(ecpm, ad_details) do
    index =
      ad_details
      |> Enum.map(& &1.ecpm)
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.find_index(fn amount -> amount == ecpm end)

    index + 1
  end

  @spec display_rate(%AdService.Advertisement{}, [%AdService.Advertisement{}]) :: map
  defp display_rate(
         %AdService.Advertisement{campaign_id: campaign_id, ecpm: ecpm},
         ad_details
       ) do
    multiplier = AdService.Math.Multiplier.calculate(ecpm, ad_details)
    display_rate = multiplier / AdService.Math.Multiplier.sum(ad_details) * 100

    %{campaign_id: campaign_id, display_rate: display_rate}
  end
end
