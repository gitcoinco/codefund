defmodule CodeSponsorWeb.TrackController do
  use CodeSponsorWeb, :controller

  alias CodeSponsor.Repo
  alias CodeSponsor.Impressions
  alias CodeSponsor.Clicks
  alias CodeSponsor.Properties
  alias CodeSponsor.Sponsorships

  @transparent_png <<71, 73, 70, 56, 57, 97, 1, 0, 1, 0, 128, 0, 0, 0, 0, 0, 255, 255, 255, 33, 249, 4, 1, 0, 0, 0, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 1, 68, 0, 59>>

  def pixel(conn, %{"property_id" => property_id} = params) do
    try do
      property = Properties.get_property!(property_id)
      sponsorship = Sponsorships.get_sponsorship_for_property(property)
      track_impression(conn, property, sponsorship, params)
    rescue
      Ecto.NoResultsError -> IO.puts("Property is missing with ID [#{property_id}]")
    end
    
    conn
    |> put_resp_content_type("image/png")
    |> send_resp(200, @transparent_png)
  end

  def click(conn, %{"property_id" => property_id} = params) do
    try do
      property = Properties.get_property!(property_id)
      sponsorship = Repo.preload(property, :sponsorship).sponsorship
      
      track_click(conn, property, sponsorship, params)
    
      redirect conn, external: sponsorship.redirect_url
      
    rescue
      Ecto.NoResultsError ->
        IO.puts("Property is missing with ID [#{property_id}]")
        redirect conn, external: "/"
    end
  end

  defp track_impression(conn, property, sponsorship, params) do
    ip_address  = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    user_agent  = conn |> get_req_header("user-agent") |> Enum.at(0)
    is_bot      = Browser.bot?(conn)
    browser     = Browser.name(user_agent)
    os          = Atom.to_string(Browser.platform(user_agent))
    device_type = parse_device_type(user_agent)

    impression_params = %{
      property_id:    property.id,
      ip:             ip_address,
      is_bot:         is_bot,
      browser:        browser,
      os:             os,
      device_type:    device_type,
      city:           nil,
      region:         nil,
      postal_code:    nil,
      country:        nil,
      latitude:       nil,
      longitude:      nil,
      screen_height:  nil,
      screen_width:   nil,
      user_agent:     user_agent,
      utm_campaign:   params["utm_campaign"],
      utm_content:    params["utm_content"],
      utm_medium:     params["utm_medium"],
      utm_source:     params["utm_source"],
      utm_term:       params["utm_term"]
    }

    if sponsorship do
      impression_params = Map.merge(impression_params, %{
        campaign_id:    sponsorship.campaign_id,
        sponsorship_id: sponsorship.id,
      })
    end

    case Impressions.create_impression(impression_params) do
      {:ok, impression} ->
        Exq.enqueue(Exq, "cs_low", CodeSponsorWeb.UpdateImpressionGeolocationWorker, [impression.id])
        IO.puts("Saved impression")
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("Unable to save impression: #{inspect(changeset)}")
    end
  end

  defp track_click(conn, property, sponsorship, params) do
    ip_address       = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    user_agent       = conn |> get_req_header("user-agent") |> Enum.at(0)
    referrer         = conn |> get_req_header("referer") |> Enum.at(0)
    is_bot           = Browser.bot?(conn)
    browser          = Browser.name(user_agent)
    os               = Atom.to_string(Browser.platform(user_agent))
    referring_domain = URI.parse(referrer).host
    device_type      = parse_device_type(user_agent)

    # Override of Browser method `device_type` because it wasn't working

    click_params = %{
      property_id:      property.id,
      ip:               ip_address,
      is_bot:           is_bot,
      landing_page:     conn.request_path,
      referrer:         referrer,
      referring_domain: referring_domain,
      browser:          browser,
      os:               os,
      device_type:      device_type,
      city:             nil,
      region:           nil,
      postal_code:      nil,
      country:          nil,
      latitude:         nil,
      longitude:        nil,
      screen_height:    nil,
      screen_width:     nil,
      user_agent:       user_agent,
      utm_campaign:     params["utm_campaign"],
      utm_content:      params["utm_content"],
      utm_medium:       params["utm_medium"],
      utm_source:       params["utm_source"],
      utm_term:         params["utm_term"]
    }

    if sponsorship do
      click_params = Map.merge(click_params, %{
        campaign_id:    sponsorship.campaign_id,
        sponsorship_id: sponsorship.id,
      })
    end

    case Clicks.create_click(click_params) do
      {:ok, click} ->
        Exq.enqueue(Exq, "cs_low", CodeSponsorWeb.UpdateClickGeolocationWorker, [click.id])
        IO.puts("Saved click")
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("Unable to save click: #{inspect(changeset)}")
    end
  end

  defp parse_device_type(user_agent) do
    cond do
      Browser.mobile?(user_agent)  -> "mobile"
      Browser.tablet?(user_agent)  -> "tablet"
      Browser.console?(user_agent) -> "console"
      Browser.known?(user_agent)   -> "desktop"
      true                         -> "unknown"
    end
  end

end