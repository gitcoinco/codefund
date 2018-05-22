defmodule Framework.Geolocation do
  require Logger

  @spec find_country_by_ip({integer, integer, integer, integer}) :: boolean
  def find_country_by_ip(ip) when is_tuple(ip) do
    try do
      ip
      |> tuple_size()
      |> cast_ip_address(stub_ip_for_dev(ip))
      |> Geolix.lookup(as: :struct, where: :country)
      |> Map.get(:country)
      |> Map.get(:iso_code)
    rescue
      _exception ->
        Logger.error("An error occurred during geolocation")
        true
    end
  end

  @spec cast_ip_address(integer, {integer}) :: {integer}
  defp cast_ip_address(4, ip), do: ip

  defp cast_ip_address(8, ip) do
    ip
    |> Tuple.to_list()
    |> Enum.map(fn element -> Integer.parse(element, 16) |> elem(0) end)
    |> List.to_tuple()
  end

  @spec stub_ip_for_dev({integer, integer, integer, integer}) ::
          {integer, integer, integer, integer}
  defp stub_ip_for_dev({127, 0, 0, 1}), do: {8, 8, 8, 8}

  defp stub_ip_for_dev(ip), do: ip
end
