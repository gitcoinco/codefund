defmodule Framework.Geolocation do
  @spec find_by_ip({integer, integer, integer, integer}, atom) ::
          {:ok, map | String.t()} | {:error, :could_not_resolve}
  def find_by_ip(ip, lookup_type) when is_tuple(ip) do
    result =
      ip
      |> tuple_size()
      |> cast_ip_address(stub_ip_for_dev(ip))
      |> Geolix.lookup(as: :struct, where: lookup_type)
      |> Framework.Geolocation.Protocol.parse()

    {:ok, result}
  end

  @spec cast_ip_address(integer, tuple) :: tuple
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
