defmodule CodeFundWeb.UpdateImpressionGeolocationWorker do
  alias CodeFund.Impressions

  def perform(impression_id) do
    impression = Impressions.get_impression!(impression_id)

    case GeoIP.lookup(impression.ip) do
      {:ok, location} ->
        location_data = %{
          "city"        => location.city,
          "region"      => location.region_name,
          "postal_code" => location.zip_code,
          "country"     => location.country_code,
          "latitude"    => location.latitude,
          "longitude"   => location.longitude,
        }
        Impressions.update_impression(impression, location_data)

      {:error, %GeoIP.Error{reason: _reason}} ->
        IO.puts("Unable to find geolocation for IP: #{impression.ip}")
    end

  end
end
