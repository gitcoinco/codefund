defprotocol Framework.Geolocation.Protocol do
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
  import CodeFund.Reporter

  def parse(result) do
    try do
      %Geolix.Result.City{
        city: %Geolix.Record.City{
          name: city_name
        },
        country: %Geolix.Record.Country{
          iso_code: country_iso_code
        },
        location: %Geolix.Record.Location{
          latitude: latitude,
          longitude: longitude
        },
        postal: %Geolix.Record.Postal{
          code: postal_code
        },
        subdivisions: [
          %Geolix.Record.Subdivision{
            name: region_name
          }
        ]
      } = result

      %{
        city: city_name,
        country: country_iso_code,
        latitude: latitude,
        longitude: longitude,
        postal_code: postal_code,
        region: region_name
      }
    rescue
      exception ->
        report(
          :error,
          exception,
          "Geolocation protocol parsing error, #{result |> Poison.encode!()}"
        )

        %Geolix.Result.City{
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
        } = result

        %{
          city: city_name,
          country: country_iso_code,
          latitude: latitude,
          longitude: longitude,
          postal_code: "",
          region: ""
        }
    end
  end
end
