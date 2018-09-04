defprotocol Framework.Geolocation.Protocol do
  @fallback_to_any true

  @spec parse(struct) :: map | String.t()
  def parse(date)
end

defimpl Framework.Geolocation.Protocol, for: Geolix.Result.Country do
  def parse(result) do
    result
    |> Map.get(:country)
    |> Map.get(:iso_code)
  end
end

defimpl Framework.Geolocation.Protocol, for: Geolix.Result.City do
  def parse(%Geolix.Result.City{country: %Geolix.Record.Country{iso_code: iso_code}, city: nil}),
    do: %{
      city: "",
      country: iso_code,
      latitude: "",
      longitude: "",
      postal_code: "",
      region: "",
      time_zone: ""
    }

  def parse(%Geolix.Result.City{
        city: %Geolix.Record.City{
          name: city_name
        },
        registered_country: %Geolix.Record.Country{
          iso_code: country_iso_code
        },
        country: nil,
        location: %Geolix.Record.Location{
          latitude: latitude,
          longitude: longitude,
          time_zone: time_zone
        },
        postal: %Geolix.Record.Postal{
          code: postal_code
        },
        subdivisions: [
          %Geolix.Record.Subdivision{
            name: region_name
          }
        ]
      }) do
    %{
      city: city_name,
      country: country_iso_code,
      latitude: latitude,
      longitude: longitude,
      postal_code: postal_code,
      region: region_name,
      time_zone: time_zone
    }
  end

  def parse(%Geolix.Result.City{
        city: %Geolix.Record.City{
          name: city_name
        },
        country: %Geolix.Record.Country{
          iso_code: country_iso_code
        },
        location: %Geolix.Record.Location{
          latitude: latitude,
          longitude: longitude,
          time_zone: time_zone
        },
        postal: %Geolix.Record.Postal{
          code: postal_code
        },
        subdivisions: [
          %Geolix.Record.Subdivision{
            name: region_name
          }
        ]
      }) do
    %{
      city: city_name,
      country: country_iso_code,
      latitude: latitude,
      longitude: longitude,
      postal_code: postal_code,
      region: region_name,
      time_zone: time_zone
    }
  end

  def parse(%Geolix.Result.City{
        city: %Geolix.Record.City{
          name: city_name
        },
        country: %Geolix.Record.Country{
          iso_code: country_iso_code
        },
        location: %Geolix.Record.Location{
          latitude: latitude,
          longitude: longitude
        }
      }) do
    %{
      city: city_name,
      country: country_iso_code,
      latitude: latitude,
      longitude: longitude,
      postal_code: "",
      region: "",
      time_zone: ""
    }
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
end
