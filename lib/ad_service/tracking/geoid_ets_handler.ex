defmodule AdService.Tracking.GeoIDETSHandler do
  import CodeFund.Reporter

  @spec import_geo_id_csv(atom) :: {:ok, atom}
  def import_geo_id_csv(table_name) do
    :ets.new(table_name, [:set, :protected, :named_table])

    Mix.env()
    |> get_priv_dir()
    |> File.stream!()
    |> CSV.decode()
    |> Enum.map(&:ets.insert_new(table_name, &1 |> elem(1) |> List.to_tuple()))
    |> Stream.run()

    {:ok, table_name}
  end

  @spec fetch_geo_id(atom, String.t() | nil, String.t() | nil, String.t() | nil) ::
          {:ok, String.t()} | {:error, :no_matching_geo_id}
  def fetch_geo_id(_, nil, nil, nil), do: {:error, :no_matching_geo_id}

  def fetch_geo_id(table_name, city, region, country) do
    with location <- [city, region, :_, country],
         [[geo_id]] <- :ets.match(table_name, sanitize_ets_match(location)) do
      report(:warning, "GeoID look up succeeded -
          geo_id: #{geo_id},
          city: #{city},
          region: #{region},
          country: #{country}")
      {:ok, geo_id}
    else
      [] ->
        report(:warning, "GeoID look up failed with parameters -
        city: #{city},
        region: #{region},
        country: #{country}")
        {:error, :no_matching_geo_id}
    end
  end

  defp sanitize_ets_match(collection) do
    Enum.with_index(collection)
    |> sanitize_ets_match(collection)
  end

  defp sanitize_ets_match([], collection), do: [:"$1" | collection] |> List.to_tuple()

  defp sanitize_ets_match([{element, index} | tail], collection) do
    collection =
      case Enum.member?(["", nil], element) do
        true -> List.replace_at(collection, index, :_)
        false -> collection
      end

    sanitize_ets_match(tail, collection)
  end

  defp get_priv_dir(:prod),
    do: Path.expand("~/priv/ga/2018-07-02-geoid.csv", __DIR__)

  defp get_priv_dir(_env),
    do: Path.expand("../../../priv/ga/2018-07-02-geoid.csv", __DIR__)
end
