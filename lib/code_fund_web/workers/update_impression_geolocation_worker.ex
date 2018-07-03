defmodule CodeFundWeb.UpdateImpressionGeolocationWorker do
  alias CodeFund.Schema.Impression
  alias CodeFund.Impressions
  import CodeFund.Reporter

  def perform(impression_id) do
    %Impression{ip: ip} = impression = Impressions.get_impression!(impression_id)
    ip_tuple = ip |> String.split(".") |> Enum.map(&String.to_integer(&1)) |> List.to_tuple()

    case Framework.Geolocation.find_by_ip(ip_tuple, :city) do
      {:ok, location} ->
        location_data = %{
          "city" => location.city,
          "region" => location.region_name,
          "postal_code" => location.zip_code,
          "country" => location.country_code,
          "latitude" => location.latitude,
          "longitude" => location.longitude
        }

        Impressions.update_impression(impression, location_data)

      {:error, :could_not_resolve} ->
        report(:error)
    end
  end
end
