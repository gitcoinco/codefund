defmodule CodeSponsorWeb.UpdateClickGeolocationWorker do
  alias CodeSponsor.Clicks

  def perform(click_id) do
    click = Clicks.get_click!(click_id)

    case GeoIP.lookup(click.ip) do
      {:ok, location} ->
        location_data = %{
          "city"        => location.city,
          "region"      => location.region_name,
          "postal_code" => location.zip_code,
          "country"     => location.country_code,
          "latitude"    => location.latitude,
          "longitude"   => location.longitude,
        }
        Clicks.update_click(click, location_data)

      {:error, %GeoIP.Error{reason: reason}} ->
        IO.puts("Unable to find geolocation for IP: #{click.ip}")
    end

  end
end
