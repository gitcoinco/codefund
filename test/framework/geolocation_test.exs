defmodule Framework.GeolocationTest do
  use ExUnit.Case

  setup do
    Application.put_env(:geolix, :banned_countries, "CN,IN,JP")
  end

  describe "find_country_by_ip/1 ipv4" do
    test "returns the country code" do
      assert Framework.Geolocation.find_country_by_ip({163, 177, 112, 32}) == "CN"
    end
  end

  describe "find_country_by_ip/1 ipv6" do
    test "returns the country code" do
      assert Framework.Geolocation.find_country_by_ip(
               {"2001", "240", "29c4", "0000", "0000", "0000", "0000", "0000"}
             ) == "JP"
    end
  end
end
