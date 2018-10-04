defprotocol Framework.Geolocation.Protocol do
  @fallback_to_any true

  @spec parse(struct) :: map | String.t()
  def parse(struct)
end

defimpl Framework.Geolocation.Protocol, for: Geolix.Result.Country do
  def parse(result) do
    case result do
      %Geolix.Result.Country{country: %Geolix.Record.Country{iso_code: country_iso_code}} ->
        country_iso_code

      %Geolix.Result.Country{
        registered_country: %Geolix.Record.Country{iso_code: country_iso_code}
      } ->
        country_iso_code

      _ ->
        ""
    end
  end
end

defimpl Framework.Geolocation.Protocol, for: Geolix.Result.City do
  def parse(city_struct) do
    parsed_country =
      case city_struct.country do
        nil -> Framework.Geolocation.Record.Protocol.parse(city_struct.registered_country)
        _ -> Framework.Geolocation.Record.Protocol.parse(city_struct.country)
      end

    parsed_location_map =
      case city_struct.location do
        nil -> %{result: %{latitude: "", longitude: "", time_zone: ""}}
        _ -> Framework.Geolocation.Record.Protocol.parse(city_struct.location)
      end

    parsed_city = Framework.Geolocation.Record.Protocol.parse(city_struct.city)
    parsed_code = Framework.Geolocation.Record.Protocol.parse(city_struct.postal)
    parsed_subdivision = Framework.Geolocation.Record.Protocol.parse(city_struct.subdivisions)

    %{
      city: parsed_city.result,
      country: parsed_country.result,
      latitude: parsed_location_map.result.latitude,
      longitude: parsed_location_map.result.longitude,
      postal_code: parsed_code.result,
      region: parsed_subdivision.result,
      time_zone: parsed_location_map.result.time_zone
    }
  end
end

defimpl Framework.Geolocation.Protocol, for: Any do
  def parse(_),
    do: %{
      city: "",
      country: "",
      latitude: "",
      longitude: "",
      postal_code: "",
      region: "",
      time_zone: ""
    }
end
