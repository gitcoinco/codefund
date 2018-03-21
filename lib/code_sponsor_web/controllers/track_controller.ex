defmodule CodeSponsorWeb.TrackController do
  use CodeSponsorWeb, :controller
  alias CodeSponsor.{Impressions, Clicks, Properties, Sponsorships}

  @transparent_png <<71, 73, 70, 56, 57, 97, 1, 0, 1, 0, 128, 0, 0, 0, 0, 0, 255, 255, 255, 33, 249, 4, 1, 0, 0, 0, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 1, 68, 0, 59>>

  def pixel(conn, %{"property_id" => property_id} = params) do
    try do
      property = Properties.get_property!(property_id)
      sponsorship = Sponsorships.get_sponsorship_for_property(property)

      impression_id =
        case track_impression(conn, property, sponsorship, params) do
          {:ok, impression} ->
            impression.id
          {:error, _} -> nil
        end

      if impression_id !== nil do
        enqueue_worker(CodeSponsorWeb.UpdateImpressionGeolocationWorker, [impression_id])
      end

      conn
      |> put_resp_content_type("image/png")
      |> put_private(:impression_id, impression_id)
      |> send_resp(200, @transparent_png)

    rescue
      Ecto.NoResultsError -> :ok

      conn
      |> put_resp_content_type("image/png")
      |> put_private(:impression_id, "")
      |> send_resp(200, @transparent_png)
    end
  end

  # TODO - This function is too complex! Refactor is necessary
  def click(conn, %{"property_id" => property_id} = params) do
    try do
      property = Properties.get_property!(property_id)
      sponsorship = Sponsorships.get_sponsorship_for_property(property)

      case track_click(conn, property, sponsorship, params) do
        {:ok, click} ->
          enqueue_worker(CodeSponsorWeb.UpdateClickGeolocationWorker, [click.id])

          no_rev_dist = %{
            revenue_amount: Decimal.new(0),
            distribution_amount: Decimal.new(0)
          }

          cond do
            sponsorship == nil ->
              Clicks.set_status(click, :no_sponsor, no_rev_dist)
            click.is_bot ->
              Clicks.set_status(click, :bot, no_rev_dist)
            click.is_duplicate ->
              Clicks.set_status(click, :duplicate, no_rev_dist)
            true ->
              # Redirect to the fraud check URL if present
              campaign = sponsorship.campaign

              if campaign.fraud_check_url do
                Clicks.set_status(click, :fraud_check, %{
                  fraud_check_redirected_at: Timex.now()
                })

                # Enqueue the verify click redirected worker for 2 minutes from now
                enqueue_worker_in(120, CodeSponsorWeb.VerifyClickRedirected, [click.id])

                redirect conn, external: "#{campaign.fraud_check_url}?utm_content=#{click.id}"
              else
                revenue = Money.new(sponsorship.bid_amount, :USD)

                revenue_rate = cond do
                  sponsorship.override_revenue_rate != nil -> sponsorship.override_revenue_rate
                  true -> sponsorship.property.user.revenue_rate
                end

                distribution = case Money.mult(revenue, revenue_rate) do
                  {:ok, amount} -> Money.round(amount).amount
                  {:error, _}   -> 0
                end

                Clicks.set_status(click, :redirected, %{
                  revenue_amount: revenue.amount,
                  distribution_amount: distribution
                })
              end
          end

        {:error, %Ecto.Changeset{} = changeset} ->
          IO.puts("Unable to save click: #{inspect(changeset)}")
      end

      if sponsorship do
        redirect conn, external: sponsorship.redirect_url
      else
        redirect conn, external: "/?utm_content=no-sponsor&utm_term=#{property.id}"
      end
    rescue
      Ecto.NoResultsError ->
        IO.puts("Property is missing with ID [#{property_id}]")
        redirect conn, external: "/?utm_content=no-property"
    end
  end

  def improvely_inbound(conn, %{"campaign_id" => _campaign_id, "utm_content" => click_id}) do
    click = Clicks.get_click!(click_id) |> CodeSponsor.Repo.preload(:sponsorship)
    sponsorship = click.sponsorship

    revenue = Money.new(sponsorship.bid_amount, :USD)

    revenue_rate = cond do
      sponsorship.override_revenue_rate != nil -> sponsorship.override_revenue_rate
      true -> sponsorship.property.user.revenue_rate
    end

    distribution = case Money.mult(revenue, revenue_rate) do
      {:ok, amount} -> Money.round(amount).amount
      {:error, _}   -> 0
    end

    Clicks.set_status(click, :redirected, %{
      revenue_amount: revenue.amount,
      distribution_amount: distribution
    })

    uri = URI.parse(sponsorship.redirect_url)
    new_query = case uri.query do
      nil -> "?cs_id=#{click_id}"
      _ -> "#{uri.query}&cs_id=#{click_id}"
    end

    url = "#{uri.scheme}://#{uri.host}#{uri.path}?#{new_query}"

    redirect conn, external: url
  end

  defp track_impression(conn, property, sponsorship, params) do
    ip_address  = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    user_agent  = conn |> get_req_header("user-agent") |> Enum.at(0)
    is_bot      = Browser.bot?(user_agent)
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
      Impressions.create_impression(impression_params)
    else
      Impressions.create_impression(impression_params)
    end
  end

  defp track_click(conn, property, sponsorship, params) do
    ip_address       = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    user_agent       = conn |> get_req_header("user-agent") |> Enum.at(0)
    referrer         = conn |> get_req_header("referer") |> Enum.at(0)
    is_bot           = Browser.bot?(conn)
    browser          = Browser.name(user_agent)
    os               = Atom.to_string(Browser.platform(user_agent))
    device_type      = parse_device_type(user_agent)

    referring_domain =
      if referrer do
        URI.parse(referrer).host
      else
        nil
      end

    is_duplicate =
      if sponsorship do
        Clicks.is_duplicate?(sponsorship.id, ip_address)
      else
        false
      end

    click_params = %{
      property_id:         property.id,
      ip:                  ip_address,
      is_bot:              is_bot,
      is_duplicate:        is_duplicate,
      landing_page:        conn.request_path,
      referrer:            referrer,
      referring_domain:    referring_domain,
      browser:             browser,
      os:                  os,
      device_type:         device_type,
      city:                nil,
      region:              nil,
      postal_code:         nil,
      country:             nil,
      latitude:            nil,
      longitude:           nil,
      screen_height:       nil,
      screen_width:        nil,
      user_agent:          user_agent,
      utm_campaign:        params["utm_campaign"],
      utm_content:         params["utm_content"],
      utm_medium:          params["utm_medium"],
      utm_source:          params["utm_source"],
      utm_term:            params["utm_term"],
      revenue_amount:      0,
      distribution_amount: 0
    }


    click_params = if sponsorship do
      Map.merge(click_params, %{
        campaign_id:    sponsorship.campaign_id,
        sponsorship_id: sponsorship.id,
      })
    end

    case Clicks.create_click(click_params) do
      {:ok, click} ->
        {:ok, click}
      {:error, %Ecto.Changeset{}} ->
        {:error, nil}
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


  # See https://github.com/akira/exq/issues/199
  defp enqueue_worker(worker, args) do
    if Mix.env == :test do
      apply(worker, :perform, args)
    else
      Exq.enqueue(Exq, "cs_low", worker, args)
    end
  end

  defp enqueue_worker_in(duration, worker, args) do
    if Mix.env == :test do
      apply(worker, :perform, args)
    else
      Exq.enqueue_in(Exq, "cs_low", duration, worker, args)
    end
  end
end