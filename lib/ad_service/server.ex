defmodule AdService.Server do
  alias AdService.UnrenderedAdvertisement
  alias AdService.Impression.Details, as: ImpressionDetails
  alias CodeFund.{Campaigns, Properties}
  alias CodeFund.Schema.{Campaign, Property}

  @spec serve(Plug.Conn.t(), String.t(), nil | map) :: map()
  def serve(conn, property_id, opts) do
    conn = AdService.Conn.set_ip_address(conn, opts["ip_address"])

    conn = AdService.Conn.set_user_agent_header(conn, opts["user_agent"] || "")

    with {:ok, :no_cache_found} <- AdService.Impression.Cache.lookup(conn.remote_ip, property_id),
         {:ok, %{country: client_country}} <-
           Framework.Geolocation.find_by_ip(conn.remote_ip, :city),
         %Property{status: 1} = property <-
           Properties.get_property!(property_id) |> CodeFund.Repo.preload([:user]),
         :ok <- Framework.Browser.certify_human(conn),
         {:ok, ad_tuple} <-
           AdService.Query.ForDisplay.build(
             property,
             client_country,
             conn.remote_ip,
             property.excluded_advertisers
           )
           |> UnrenderedAdvertisement.all()
           |> AdService.Display.choose_winner(),
         %UnrenderedAdvertisement{campaign_id: campaign_id} = advertisement <-
           ad_tuple |> AdService.Display.render(),
         %Campaign{} = campaign <- Campaigns.get_campaign!(campaign_id),
         {:ok, _} <-
           AdService.CampaignImpressionManager.can_create_impression?(
             campaign_id,
             campaign.impression_count
           ) do
      ImpressionDetails.new(conn, property, campaign)
      |> ImpressionDetails.put_request_origin(opts["request_origin"])
      |> ImpressionDetails.put_browser_details(opts["height"], opts["width"], opts["user_agent"])
      |> AdService.Impression.Manager.create_successful_impression(advertisement)
    else
      {:ok, :cache_loaded, details} ->
        details

      %Property{} = property ->
        ImpressionDetails.new(conn, property, nil)
        |> ImpressionDetails.put_request_origin(opts["request_origin"])
        |> ImpressionDetails.put_error(:property_inactive)
        |> ImpressionDetails.put_browser_details(
          opts["height"],
          opts["width"],
          opts["user_agent"]
        )
        |> AdService.Impression.Manager.create_error_impression()

      {:error, :is_bot} ->
        AdService.AdvertisementImpression.new({:error, :is_bot})

      {:error, reason_atom} ->
        property = CodeFund.Properties.get_property!(property_id)

        ImpressionDetails.new(conn, property, nil)
        |> ImpressionDetails.put_request_origin(opts["request_origin"])
        |> ImpressionDetails.put_error(reason_atom)
        |> ImpressionDetails.put_browser_details(
          opts["height"],
          opts["width"],
          opts["user_agent"]
        )
        |> AdService.Impression.Manager.create_error_impression()
    end
  end
end
