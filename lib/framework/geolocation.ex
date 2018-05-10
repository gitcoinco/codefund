defmodule Framework.Geolocation do
  require Logger

  @spec is_banned_country?({integer, integer, integer, integer}) :: boolean
  def is_banned_country?(ip) when is_tuple(ip) do
    try do
      ip
      |> tuple_size()
      |> cast_ip_address(ip)
      |> Geolix.lookup(as: :struct, where: :country)
      |> check_against_list_of_banned_countries
    rescue
      exception ->
        IO.inspect exception
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

  @spec check_against_list_of_banned_countries(%Geolix.Result.Country{}) :: boolean
  defp check_against_list_of_banned_countries(%Geolix.Result.Country{
         country: %Geolix.Record.Country{iso_code: country_code}
       }) do
    Application.get_env(:geolix, :banned_countries)
    |> String.split(",")
    |> Enum.member?(country_code)
  end
end
