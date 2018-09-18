defmodule AdService.Impression.Manager do
  alias AdService.Advertisement
  alias AdService.Impression.Details, as: ImpressionDetails
  alias CodeFund.Schema.Impression

  @spec create_successful_impression(
          ImpressionDetails.t(),
          AdService.Advertisement.t()
        ) :: map
  def create_successful_impression(
        %ImpressionDetails{} = impression_details,
        advertisement
      ) do
    {:ok, %Impression{id: impression_id}} =
      impression_details
      |> ImpressionDetails.put_financials()
      |> ImpressionDetails.save()

    payload =
      AdService.ResponseMap.for_success(
        advertisement,
        impression_details.conn,
        impression_id
      )

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
      %Advertisement{} = advertisement ->
        campaign = CodeFund.Campaigns.get_campaign!(advertisement.campaign_id)

        {:ok, %Impression{id: impression_id}} =
          impression_details
          |> ImpressionDetails.flag_house_ad(campaign)
          |> ImpressionDetails.save()

        advertisement
        |> AdService.ResponseMap.for_success(impression_details.conn, impression_id, true)

      nil ->
        {:ok, %Impression{id: impression_id}} =
          impression_details
          |> ImpressionDetails.save()

        AdService.ResponseMap.for_error(
          impression_details.error.human_readable_message,
          "//#{impression_details.host}/p/#{impression_id}/pixel.png"
        )
    end
  end

  def create_error_impression(%ImpressionDetails{} = impression_details) do
    {:ok, %Impression{id: impression_id}} =
      impression_details
      |> ImpressionDetails.save()

    AdService.ResponseMap.for_error(
      impression_details.error.human_readable_message,
      "//#{impression_details.host}/p/#{impression_id}/pixel.png"
    )
  end
end
