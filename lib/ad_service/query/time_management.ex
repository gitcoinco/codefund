defmodule AdService.Query.TimeManagement do
  import Ecto.Query
  use Timex

  @spec where_accepted_hours_for_ip_address(
          Ecto.Query.t(),
          {integer(), integer(), integer(), integer()} | nil
        ) :: Ecto.Query.t()

  def where_accepted_hours_for_ip_address(query, nil), do: query

  def where_accepted_hours_for_ip_address(query, ip_address) do
    accepted_hours_function = fn query, time_zone ->
      %DateTime{hour: hour} = TimeMachinex.now() |> Timezone.convert(time_zone)

      query
      |> build_hours_query(hour)
    end

    accepted_hours_function
    |> local_time_zone_check(query, ip_address)
  end

  @spec where_not_allowed_on_weekends(
          Ecto.Query.t(),
          {integer(), integer(), integer(), integer()} | nil
        ) :: Ecto.Query.t()
  def where_not_allowed_on_weekends(query, nil), do: query

  def where_not_allowed_on_weekends(query, ip_address) do
    no_weekends_function = fn query, time_zone ->
      day_of_week_int =
        TimeMachinex.now()
        |> Timezone.convert(time_zone)
        |> Date.day_of_week()

      query
      |> build_allowed_on_weekends_query(day_of_week_int)
    end

    no_weekends_function
    |> local_time_zone_check(query, ip_address)
  end

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

  defp build_allowed_on_weekends_query(query, day_of_week_int) when day_of_week_int < 6, do: query

  defp build_allowed_on_weekends_query(query, _) do
    query
    |> where([_creative, campaign, ...], campaign.weekdays_only == false)
  end

  defp local_time_zone_check(function, query, ip_address) do
    with {:ok, %{time_zone: time_zone}} when time_zone != "" <-
           ip_address |> Framework.Geolocation.find_by_ip(:city) do
      function.(query, time_zone)
    else
      _ -> query
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

  defp build_hours_query(query, hour) when hour > 5 and hour < 21, do: query

  # JBEAN TODO: refactor this
  defp build_hours_query(query, _), do: query |> where("false")
end
