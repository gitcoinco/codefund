defmodule Framework.Geolocation do
  @spec is_banned_country?({integer, integer, integer, integer}) :: boolean
  def is_banned_country?(ip) when is_tuple(ip) do
    ip
    |> Geolix.lookup(as: :struct, where: :country)
    |> check_against_list_of_banned_countries
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
