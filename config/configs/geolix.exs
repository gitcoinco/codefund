use Mix.Config

config :geolix,
  databases: [
    %{
      id: :country,
      adapter: Geolix.Adapter.MMDB2,
      init: {MaxMindInitializer, :init}
    },
    %{
      id: :city,
      adapter: Geolix.Adapter.MMDB2,
      init: {MaxMindInitializer, :init}
    }
  ],
  banned_countries: System.get_env("BANNED_COUNTRIES") || [],
  mmdb_country_location: System.get_env("MMDB_COUNTRY_LOCATION") || "",
  mmdb_city_location: System.get_env("MMDB_CITY_LOCATION") || ""
