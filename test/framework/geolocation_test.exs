defmodule Framework.GeolocationTest do
  use ExUnit.Case

  setup do
    Application.put_env(:geolix, :banned_countries, "CN,IN,JP")
  end

  describe "find_by_ip/1 ipv4" do
    test "returns the country code" do
      assert Framework.Geolocation.find_by_ip({163, 177, 112, 32}, :country) == {:ok, "CN"}
    end

    test "returns an empty location map if country lookup fails" do
      assert Framework.Geolocation.find_by_ip({999, 999, 999, 999}, :country) ==
               {:ok,
                %{
                  city: "",
                  country: "",
                  latitude: "",
                  longitude: "",
                  postal_code: "",
                  region: ""
                }}
    end

    test "returns the city details" do
      assert Framework.Geolocation.find_by_ip({67, 139, 178, 66}, :city) ==
               {:ok,
                %{
                  city: "Portland",
                  country: "US",
                  latitude: 45.5171,
                  longitude: -122.6802,
                  postal_code: "97205",
                  region: "Oregon"
                }}
    end

    test "returns an empty location map if city look up fails" do
      assert Framework.Geolocation.find_by_ip({999, 999, 999, 999}, :city) ==
               {:ok,
                %{
                  city: "",
                  country: "",
                  latitude: "",
                  longitude: "",
                  postal_code: "",
                  region: ""
                }}
    end
  end

  describe "find_by_ip/1 ipv6" do
    test "returns the country code" do
      assert Framework.Geolocation.find_by_ip(
               {"2001", "240", "29c4", "0000", "0000", "0000", "0000", "0000"},
               :country
             ) == {:ok, "JP"}
    end

    test "returns an empty location map if country lookup fails" do
      assert Framework.Geolocation.find_by_ip(
               {"9999", "9999", "9999", "9999", "9989", "9999", "9999", "9999"},
               :country
             ) ==
               {:ok,
                %{
                  city: "",
                  country: "",
                  latitude: "",
                  longitude: "",
                  postal_code: "",
                  region: ""
                }}
    end

    test "returns the city details" do
      assert Framework.Geolocation.find_by_ip(
               {"2001", "240", "29c4", "0000", "0000", "0000", "0000", "0000"},
               :city
             ) ==
               {:ok,
                %{
                  city: "Tokyo",
                  country: "JP",
                  latitude: 35.685,
                  longitude: 139.7514,
                  postal_code: "102-0082",
                  region: "Tokyo"
                }}
    end

    test "returns an empty location map if city look up fails" do
      assert Framework.Geolocation.find_by_ip(
               {"9999", "9999", "9999", "9999", "9989", "9999", "9999", "9999"},
               :city
             ) ==
               {:ok,
                %{
                  city: "",
                  country: "",
                  latitude: "",
                  longitude: "",
                  postal_code: "",
                  region: ""
                }}
    end
  end
end
