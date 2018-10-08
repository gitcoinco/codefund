defmodule Framework.Geolocation.Record.ProtocolTest do
  use ExUnit.Case

  setup do
    city_record = %Geolix.Record.City{
      geoname_id: 5_746_545,
      name: "Portland",
      names: %{
        de: "Portland",
        en: "Portland",
        es: "Portland",
        fr: "Portland",
        ja: "ポートランド",
        "pt-BR": "Portland",
        ru: "Портленд"
      }
    }

    country_record = %Geolix.Record.Country{
      geoname_id: 6_252_001,
      iso_code: "US",
      name: "United States",
      names: %{
        de: "USA",
        en: "United States",
        es: "Estados Unidos",
        fr: "États-Unis",
        ja: "アメリカ合衆国",
        "pt-BR": "Estados Unidos",
        ru: "США",
        "zh-CN": "美国"
      }
    }

    location_record = %Geolix.Record.Location{
      accuracy_radius: 1000,
      latitude: 45.5171,
      longitude: -122.6802,
      metro_code: 820,
      time_zone: "America/Los_Angeles"
    }

    postal_record = %Geolix.Record.Postal{code: "97205"}

    registered_country_record = %Geolix.Record.Country{
      geoname_id: 6_252_001,
      iso_code: "US",
      name: "United States",
      names: %{
        de: "USA",
        en: "United States",
        es: "Estados Unidos",
        fr: "États-Unis",
        ja: "アメリカ合衆国",
        "pt-BR": "Estados Unidos",
        ru: "США",
        "zh-CN": "美国"
      }
    }

    subdivisions_record = [
      %Geolix.Record.Subdivision{
        geoname_id: 5_744_337,
        iso_code: "OR",
        name: "Oregon",
        names: %{
          de: "Oregon",
          en: "Oregon",
          es: "Oregón",
          fr: "Oregon",
          ja: "オレゴン州",
          "pt-BR": "Oregão",
          ru: "Орегон",
          "zh-CN": "俄勒冈州"
        }
      }
    ]

    {:ok,
     %{
       city_record: city_record,
       country_record: country_record,
       location_record: location_record,
       registered_country_record: registered_country_record,
       postal_record: postal_record,
       subdivisions_record: subdivisions_record
     }}
  end

  describe "parse" do
    test "it returns result map for a city record", %{city_record: city_record} do
      assert Framework.Geolocation.Record.Protocol.parse(city_record) == %{
               result: city_record.name
             }
    end

    test "it returns result map for a country record", %{country_record: country_record} do
      assert Framework.Geolocation.Record.Protocol.parse(country_record) == %{
               result: country_record.iso_code
             }
    end

    test "it returns result map for a location record", %{location_record: location_record} do
      assert Framework.Geolocation.Record.Protocol.parse(location_record) == %{
               result: %{
                 latitude: location_record.latitude,
                 longitude: location_record.longitude,
                 time_zone: location_record.time_zone
               }
             }
    end

    test "it returns result map for a registered country record", %{
      registered_country_record: registered_country_record
    } do
      assert Framework.Geolocation.Record.Protocol.parse(registered_country_record) == %{
               result: registered_country_record.iso_code
             }
    end

    test "it returns result map for a postal record", %{postal_record: postal_record} do
      assert Framework.Geolocation.Record.Protocol.parse(postal_record) == %{
               result: postal_record.code
             }
    end

    test "it returns result map for a empty list" do
      assert Framework.Geolocation.Record.Protocol.parse([]) == %{result: ""}
    end

    test "it returns result map for a subdivisions_record", %{
      subdivisions_record: subdivisions_record
    } do
      assert Framework.Geolocation.Record.Protocol.parse(subdivisions_record) == %{
               result: subdivisions_record |> List.first() |> Map.get(:name)
             }
    end

    test "it falls back to any on nil" do
      assert Framework.Geolocation.Record.Protocol.parse(nil) == %{result: ""}
    end
  end
end
