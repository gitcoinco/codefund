defmodule AdService.Display do
  @spec render({[%AdService.Advertisement{}], {UUID.t(), Keyword.t()}}) ::
          %AdService.Advertisement{}
  def render({possible_ads, {campaign_id, _range}}) do
    possible_ads
    |> Enum.find(fn possible_ad_to_display ->
      possible_ad_to_display.campaign_id == campaign_id
    end)
  end

  @spec choose_winner([%AdService.Advertisement{}]) ::
          {:ok, {[%AdService.Advertisement{}], {UUID.t(), Keyword.t()}}}
          | {:error, :no_possible_ads}
  def choose_winner([]), do: {:error, :no_possible_ads}

  def choose_winner(possible_ads) when length(possible_ads) > 0 do
    winner =
      possible_ads
      |> AdService.Math.Basic.get_all_display_rates()
      |> pick_random_ad()

    {:ok, {possible_ads, winner}}
  end

  defp pick_random_ad(possible_ads) do
    ranges = get_ranges([], possible_ads)
    random_number = :rand.uniform(100)

    ranges
    |> Enum.find(fn {_campaign_id, range} ->
      random_number in range
    end)
  end

  @spec get_ranges([{UUID.t(), Keyword.t()}], [map]) :: [{UUID.t(), Keyword.t()}]
  defp get_ranges(ranges, []), do: ranges

  defp get_ranges([], [current_ad | tail]) do
    []
    |> add_current_range(current_ad.campaign_id, 0, current_ad.display_rate)
    |> get_ranges(tail)
  end

  defp get_ranges(ranges, [current_ad | tail]) do
    {_campaign_id, _first..prior_rate} = List.last(ranges)
    ending_point = current_ad.display_rate + prior_rate

    ranges
    |> add_current_range(current_ad.campaign_id, prior_rate, ending_point)
    |> get_ranges(tail)
  end

  @spec add_current_range([{UUID.t(), Keyword.t()}], UUID.t(), integer, integer) :: [
          {UUID.t(), Keyword.t()}
        ]
  defp add_current_range(ranges, campaign_id, starting_point, ending_point) do
    Enum.concat(ranges, [{campaign_id, starting_point..(ending_point |> trunc())}])
  end
end
