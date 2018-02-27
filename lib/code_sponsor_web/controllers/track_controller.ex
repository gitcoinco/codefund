defmodule CodeSponsorWeb.TrackController do
  use CodeSponsorWeb, :controller

  alias CodeSponsor.Repo
  alias CodeSponsor.Impressions
  alias CodeSponsor.Properties

  @transparent_png <<71, 73, 70, 56, 57, 97, 1, 0, 1, 0, 128, 0, 0, 0, 0, 0, 255, 255, 255, 33, 249, 4, 1, 0, 0, 0, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 1, 68, 0, 59>>

  def pixel(conn, %{"property_id" => property_id} = params) do
    property = Properties.get_property!(property_id)
    sponsorship = Repo.preload(property, :sponsorship).sponsorship

    if sponsorship do
      track_impression(conn, sponsorship, params)
    else
      IO.puts("Sponsorship is missing for property [#{property.id}]")
    end
    
    conn
    |> put_resp_content_type("image/png")
    |> send_resp(200, @transparent_png)
  end

  defp track_impression(conn, sponsorship, params) do

    IO.puts(params["utm_foo"])
    IO.puts(inspect(params))

    ip_address = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    user_agent = conn |> get_req_header("user-agent") |> Enum.at(0)
    is_bot     = Browser.bot?(conn)
    browser    = Browser.name(user_agent)
    os         = Atom.to_string(Browser.platform(user_agent))

    impression_params = %{
      property_id:    sponsorship.property_id,
      campaign_id:    sponsorship.campaign_id,
      sponsorship_id: sponsorship.id,
      ip:             ip_address,
      browser:        browser,
      os:             os,
      device_type:    nil, # Browser.device_type(user_agent),
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

    case Impressions.create_impression(impression_params) do
      {:ok, impression} ->
        Exq.enqueue(Exq, "cs_low", CodeSponsorWeb.UpdateImpressionGeolocationWorker, [impression.id])
        IO.puts("Saved impression")
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("Unable to save impression: #{inspect(changeset)}")
    end
  end

end