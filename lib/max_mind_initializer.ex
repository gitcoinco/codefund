defmodule MaxMindInitializer do
  @spec init(map) :: map
  def init(database) do
    File.ls(get_priv_dir(Mix.env()))
    |> write_max_mind_db()

    databases = [
      %{
        id: :country,
        adapter: Geolix.Adapter.MMDB2,
        source: get_priv_dir(Mix.env())
      }
      | Application.get_env(:geolix, :databases, [])
    ]

    Application.put_env(:geolix, :databases, databases)
    Map.put(database, :source, get_priv_dir(Mix.env()))
  end

  def get_priv_dir(:prod), do: "/tmp/GeoIP2-Country.mmdb"

  def get_priv_dir(_env), do: Path.expand("../priv/maxmind/GeoIP2-Country.mmdb", __DIR__)

  defp write_max_mind_db({:error, :enoent}) do
    case Application.get_env(:geolix, :mmdb_location) do
      nil ->
        raise "You must download the lite database from http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz, untar, and save as #{
                get_priv_dir(Mix.env())
              }"

      _location ->
        Mix.Tasks.Maxmind.Setup.run(nil)
    end
  end

  defp write_max_mind_db(_), do: true
end
