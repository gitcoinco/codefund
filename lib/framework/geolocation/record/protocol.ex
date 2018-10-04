defprotocol Framework.Geolocation.Record.Protocol do
  @fallback_to_any true

  @spec parse(struct) :: map
  def parse(struct)
end

defimpl Framework.Geolocation.Record.Protocol, for: Geolix.Record.City do
  def parse(city_record), do: %{result: city_record.name}
end

defimpl Framework.Geolocation.Record.Protocol, for: Geolix.Record.Country do
  def parse(country_record), do: %{result: country_record.iso_code}
end

defimpl Framework.Geolocation.Record.Protocol, for: Geolix.Record.Postal do
  def parse(postal_record), do: %{result: postal_record.code}
end

defimpl Framework.Geolocation.Record.Protocol, for: Geolix.Record.Location do
  def parse(location_struct) do
    result =
      location_struct
      |> Map.from_struct()
      |> Map.take([:latitude, :longitude, :time_zone])
      |> Map.to_list()
      |> Enum.map(fn {k, v} ->
        case v do
          nil -> {k, ""}
          _ -> {k, v}
        end
      end)
      |> Enum.into(%{})

    %{result: result}
  end
end

defimpl Framework.Geolocation.Record.Protocol, for: List do
  def parse([]) do
    Framework.Geolocation.Record.Protocol.parse(nil)
  end

  def parse(subdivisions) do
    result = subdivisions |> List.first() |> Map.get(:name)
    %{result: result}
  end
end

defimpl Framework.Geolocation.Record.Protocol, for: Any do
  def parse(_), do: %{result: ""}
end
