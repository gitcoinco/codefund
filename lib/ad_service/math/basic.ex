defmodule AdService.Math.Basic do
  @spec get_all_display_rates([map]) :: [map]
  def get_all_display_rates(ad_details) do
    ad_details
    |> Enum.map(&display_rate(&1, ad_details))
    |> Enum.sort(&(&1.display_rate > &2.display_rate))
  end

  @spec sum([map]) :: Float.t()
  def sum(ad_details) do
    ad_details
    |> Enum.map(&(Map.get(&1, "bid_amount") |> Decimal.to_float()))
    |> Enum.sum()
  end

  @spec get_weight(Decimal.t(), [map]) :: integer
  def get_weight(bid_amount, ad_details) do
    index =
      ad_details
      |> Enum.map(&Map.get(&1, "bid_amount"))
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.find_index(fn amount -> amount == bid_amount end)

    index + 1
  end

  @spec display_rate(map, [map]) :: map
  defp display_rate(%{"campaign_id" => campaign_id, "bid_amount" => bid_amount}, ad_details) do
    multiplier = AdService.Math.Multiplier.calculate(bid_amount, ad_details)
    display_rate = multiplier / AdService.Math.Multiplier.sum(ad_details) * 100

    %{campaign_id: campaign_id, display_rate: display_rate}
  end
end
