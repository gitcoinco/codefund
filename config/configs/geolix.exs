use Mix.Config

config :geolix,
  databases: [
    %{
      id: :country,
      adapter: Geolix.Adapter.MMDB2,
      init: {MaxMindInitializer, :init}
    }
  ],
  banned_countries: System.get_env("BANNED_COUNTRIES"),
  database_location: System.get_env("DATABASE_LOCATION")
