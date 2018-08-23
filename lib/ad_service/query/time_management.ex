defmodule AdService.Query.TimeManagement do
  import Ecto.Query

  @spec optionally_exclude_us_hours_only_campaigns(Ecto.Query.t()) :: Ecto.Query.t()
  def optionally_exclude_us_hours_only_campaigns(query) do
    case now_as_interval() |> current_time_is_during_us_hours?() do
      true ->
        query

      false ->
        query
        |> where([_creative, campaign, ...], campaign.us_hours_only == false)
    end
  end

  @spec current_time_is_during_us_hours?(Timex.Interval.t()) :: boolean()
  defp current_time_is_during_us_hours?(time_to_check) do
    [from: pst_5am(), until: [hours: 12]]
    |> Timex.Interval.new()
    |> Timex.Interval.overlaps?(time_to_check)
  end

  defp pst_5am, do: TimeMachinex.now() |> Map.merge(%{hour: 12, minute: 00, second: 00})

  defp now_as_interval do
    [from: TimeMachinex.now(), until: [hours: 0]]
    |> Timex.Interval.new()
  end
end
