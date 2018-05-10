defmodule MaxMindInitializer do
  @spec init(map) :: map
  def init(database) do
    maxmind_db = Application.get_env(:geolix, :mmdb_location) |> HTTPoison.get!()

    File.write(get_priv_dir(Mix.env), maxmind_db.body)

    databases = [
      %{
        id: :country,
        adapter: Geolix.Adapter.MMDB2,
        source: get_priv_dir(Mix.env)
      }
      | Application.get_env(:geolix, :databases, [])
    ]

    Application.put_env(:geolix, :databases, databases)
    Map.put(database, :source, get_priv_dir(Mix.env))
  end

  defp get_priv_dir(:prod), do: "/app/_build/prod/lib/code_fund/priv/maxmind"
  defp get_priv_dir(_), do: Path.expand("../priv/maxmind/GeoIP2-Country.mmdb", __DIR__)
end
