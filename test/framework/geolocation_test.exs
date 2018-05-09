defmodule Framework.GeolocationTest do
  use ExUnit.Case

  setup do
    Application.put_env(:geolix, :banned_countries, "CN,IN")
  end

  describe "is_banned_country?/1" do
    test "returns true if the IP is from a country in the banned country" do
      assert Framework.Geolocation.is_banned_country?({163, 177, 112, 32})
    end

    test "returns false if the IP is not from a country in the banned country" do
      refute Framework.Geolocation.is_banned_country?({12, 109, 12, 14})
    end
  end
end
