defmodule MaxMindInitializer do
  @spec init(map) :: map
  def init(database) do
    File.ls(get_priv_dir(Mix.env(), :country))
    |> write_max_mind_db(:country)

    File.ls(get_priv_dir(Mix.env(), :city))
    |> write_max_mind_db(:city)

    databases = [
      db_map(:country),
      db_map(:city)
      | Application.get_env(:geolix, :databases, [])
    ]

    Application.put_env(:geolix, :databases, databases)

    case database.id do
      :country -> Map.put(database, :source, get_priv_dir(Mix.env(), :country))
      :city -> Map.put(database, :source, get_priv_dir(Mix.env(), :city))
    end
  end

  def get_priv_dir(:prod, type) when type in [:city, :country],
    do: "/tmp/GeoIP2-#{type |> stringify()}.mmdb"

  def get_priv_dir(_env, type) when type in [:city, :country],
    do: Path.expand("../priv/maxmind/GeoIP2-#{type |> stringify()}.mmdb", __DIR__)

  defp db_map(type) when is_atom(type) do
    %{
      id: type,
      adapter: Geolix.Adapter.MMDB2,
      source: get_priv_dir(Mix.env(), type)
    }
  end

  defp write_max_mind_db({:error, :enoent}, type) do
    case Application.get_env(:geolix, :"mmdb_#{type}_location") do
      nil ->
        raise "You must download the lite #{type} database from http://geolite.maxmind.com/download/geoip/database/GeoLite2-#{
                stringify(type)
              }.tar.gz, untar, and save as #{get_priv_dir(Mix.env(), type)}"

      _location ->
        Mix.Tasks.Maxmind.Setup.run(nil)
    end
  end

  defp stringify(type), do: type |> Atom.to_string() |> String.capitalize()

  defp write_max_mind_db(_, _), do: true
end
