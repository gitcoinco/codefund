defmodule MaxMindInitializer do
  @spec init(map) :: map
  def init(database) do
    maxmind_db = Application.get_env(:geolix, :mmdb_location) |> HTTPoison.get!()

    File.write(Path.expand("../priv/maxmind/GeoIP2-Country.mmdb", __DIR__), maxmind_db.body)

    databases = [
      %{
        id: :country,
        adapter: Geolix.Adapter.MMDB2,
        source: Path.expand("../priv/maxmind/GeoIP2-Country.mmdb", __DIR__)
      }
      | Application.get_env(:geolix, :databases, [])
    ]

    Application.put_env(:geolix, :databases, databases)
    Map.put(database, :source, Path.expand("../priv/maxmind/GeoIP2-Country.mmdb", __DIR__))
  end
end
