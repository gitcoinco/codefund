defmodule Framework.Geolocation.ProtocolTest do
  use ExUnit.Case

  setup do
    city_struct = %Geolix.Result.City{
      city: %Geolix.Record.City{
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
      },
      continent: %Geolix.Record.Continent{
        code: "NA",
        geoname_id: 6_255_149,
        name: "North America",
        names: %{
          de: "Nordamerika",
          en: "North America",
          es: "Norteamérica",
          fr: "Amérique du Nord",
          ja: "北アメリカ",
          "pt-BR": "América do Norte",
          ru: "Северная Америка",
          "zh-CN": "北美洲"
        }
      },
      country: %Geolix.Record.Country{
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
      },
      location: %Geolix.Record.Location{
        accuracy_radius: 1000,
        latitude: 45.5171,
        longitude: -122.6802,
        metro_code: 820,
        time_zone: "America/Los_Angeles"
      },
      postal: %Geolix.Record.Postal{code: "97205"},
      registered_country: %Geolix.Record.Country{
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
      },
      represented_country: nil,
      subdivisions: [
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
      ],
      traits: %{ip_address: {67, 139, 178, 66}}
    }

    country_struct = %Geolix.Result.Country{
      continent: %Geolix.Record.Continent{
        code: "NA",
        geoname_id: 6_255_149,
        name: "North America",
        names: %{
          de: "Nordamerika",
          en: "North America",
          es: "Norteamérica",
          fr: "Amérique du Nord",
          ja: "北アメリカ",
          "pt-BR": "América do Norte",
          ru: "Северная Америка",
          "zh-CN": "北美洲"
        }
      },
      country: %Geolix.Record.Country{
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
      },
      registered_country: %Geolix.Record.Country{
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
      },
      represented_country: nil,
      traits: %{ip_address: {67, 139, 178, 66}}
    }

    {:ok, %{country_struct: country_struct, city_struct: city_struct}}
  end

  describe "parse" do
    test "it returns country isocode for a country struct", %{country_struct: country_struct} do
      assert Framework.Geolocation.Protocol.parse(country_struct) == "US"
    end

    test "it falls back for a country struct to registered country if country is nil", %{
      country_struct: country_struct
    } do
      country_struct = country_struct |> Map.put(:country, nil)
      assert Framework.Geolocation.Protocol.parse(country_struct) == "US"
    end

    test "it returns empty string for country struct if country and registered country are nil",
         %{country_struct: country_struct} do
      country_struct = country_struct |> Map.merge(%{country: nil, registered_country: nil})
      assert Framework.Geolocation.Protocol.parse(country_struct) == ""
    end

    test "it returns city map for a city struct", %{city_struct: city_struct} do
      assert Framework.Geolocation.Protocol.parse(city_struct) == %{
               city: "Portland",
               country: "US",
               latitude: 45.5171,
               longitude: -122.6802,
               postal_code: "97205",
               region: "Oregon",
               time_zone: "America/Los_Angeles"
             }
    end

    test "it returns city map when subdivisions are nil", %{city_struct: city_struct} do
      city_struct = city_struct |> Map.put(:subdivisions, nil)

      assert Framework.Geolocation.Protocol.parse(city_struct) == %{
               city: "Portland",
               country: "US",
               latitude: 45.5171,
               longitude: -122.6802,
               region: "",
               postal_code: "97205",
               time_zone: "America/Los_Angeles"
             }
    end

    test "it returns city map when subdivisions are empty list", %{city_struct: city_struct} do
      city_struct = city_struct |> Map.put(:subdivisions, [])

      assert Framework.Geolocation.Protocol.parse(city_struct) == %{
               city: "Portland",
               country: "US",
               latitude: 45.5171,
               longitude: -122.6802,
               region: "",
               postal_code: "97205",
               time_zone: "America/Los_Angeles"
             }
    end

    test "it defaults to registered country if country is nil for a city struct", %{
      city_struct: city_struct
    } do
      city_struct = city_struct |> Map.merge(%{country: nil})

      assert Framework.Geolocation.Protocol.parse(city_struct) == %{
               city: "Portland",
               country: "US",
               latitude: 45.5171,
               longitude: -122.6802,
               postal_code: "97205",
               region: "Oregon",
               time_zone: "America/Los_Angeles"
             }
    end

    test "it returns city map without city if city is missing in city struct", %{
      city_struct: city_struct
    } do
      city_struct = city_struct |> Map.put(:city, nil)

      assert Framework.Geolocation.Protocol.parse(city_struct) == %{
               city: "",
               country: "US",
               latitude: 45.5171,
               longitude: -122.6802,
               postal_code: "97205",
               region: "Oregon",
               time_zone: "America/Los_Angeles"
             }
    end

    test "it returns incomplete city map if location is nil", %{
      city_struct: city_struct
    } do
      city_struct = city_struct |> Map.put(:location, nil)

      assert Framework.Geolocation.Protocol.parse(city_struct) == %{
               country: "US",
               postal_code: "97205",
               region: "Oregon",
               city: "Portland",
               latitude: "",
               longitude: "",
               time_zone: ""
             }
    end

    test "it falls back to any if passed nil" do
      assert Framework.Geolocation.Protocol.parse(nil) == %{
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
end
