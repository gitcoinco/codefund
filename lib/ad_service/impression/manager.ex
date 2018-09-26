defmodule AdService.Impression.Manager do
  alias AdService.UnrenderedAdvertisement
  alias AdService.Impression.Details, as: ImpressionDetails

  @spec create_successful_impression(
          ImpressionDetails.t(),
          AdService.UnrenderedAdvertisement.t()
        ) :: map
  def create_successful_impression(
        %ImpressionDetails{} = impression_details,
        advertisement
      ) do
    {:ok, %ImpressionDetails{} = impression_details} =
      impression_details
      |> ImpressionDetails.put_financials()
      |> ImpressionDetails.save()

    payload = AdService.AdvertisementImpression.new({:ok, {impression_details, advertisement}})

    {:ok, :cache_stored} =
      payload
      |> AdService.Impression.Cache.store(
        impression_details.conn.remote_ip,
        impression_details.property.id
      )

    payload
  end

  @spec create_error_impression(ImpressionDetails.t()) :: map
  def create_error_impression(
        %ImpressionDetails{
          error: %AdService.Impression.ErrorStruct{reason_atom: :no_possible_ads}
        } = impression_details
      ) do
    case impression_details.property.id
         |> AdService.Query.ForDisplay.fallback_ad_by_property_id() do
      %UnrenderedAdvertisement{} = advertisement ->
        campaign = CodeFund.Campaigns.get_campaign!(advertisement.campaign_id)

        {:ok, %ImpressionDetails{} = saved_impression_details} =
          impression_details
          |> ImpressionDetails.flag_house_ad(campaign)
          |> ImpressionDetails.save()

        AdService.AdvertisementImpression.new({:ok, {saved_impression_details, advertisement}})

      nil ->
        {:ok, %ImpressionDetails{} = saved_impression_details} =
          impression_details
          |> ImpressionDetails.save()

        AdService.AdvertisementImpression.new({:error, {saved_impression_details}})
    end
  end

  def create_error_impression(%ImpressionDetails{} = impression_details) do
    {:ok, %ImpressionDetails{} = saved_impression_details} =
      impression_details
      |> ImpressionDetails.save()

    AdService.AdvertisementImpression.new({:error, {saved_impression_details}})
  end
end
