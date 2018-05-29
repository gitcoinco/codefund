defmodule CodeFundWeb.TrackController do
  use CodeFundWeb, :controller
  alias CodeFund.Schema.{Campaign, Click, Impression}
  alias CodeFund.{Impressions, Clicks}

  @transparent_png <<71, 73, 70, 56, 57, 97, 1, 0, 1, 0, 128, 0, 0, 0, 0, 0, 255, 255, 255, 33,
                     249, 4, 1, 0, 0, 0, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 1, 68, 0, 59>>

  def pixel(conn, %{"impression_id" => impression_id}) do
    with {:ok, %CodeFund.Schema.Impression{id: impression_id}} <-
           update_impression_with_browser_attributes(conn, impression_id),
         {:ok, _} <-
           enqueue_worker(CodeFundWeb.UpdateImpressionGeolocationWorker, [impression_id]) do
      conn
      |> put_resp_content_type("image/png")
      |> send_resp(200, @transparent_png)
    else
      {:error, _} ->
        conn
    end
  end

  def click(conn, %{"impression_id" => impression_id}) do
    with %Impression{campaign: %Campaign{} = campaign} = impression <-
           Impressions.get_impression!(impression_id)
           |> CodeFund.Repo.preload([:campaign, [property: :user]]),
         {:ok, %Click{} = click} <-
           track_click(conn, impression_id, campaign, impression.property),
         {:ok, _click_id} <- enqueue_worker(CodeFundWeb.UpdateClickGeolocationWorker, [click.id]) do
      click_redirect(conn, campaign)
    else
      %Plug.Conn{} = conn ->
        conn

      {:error, %Ecto.Changeset{} = changeset} ->
        %Impression{campaign: %Campaign{} = campaign} = Impressions.get_impression!(impression_id)
        report(:warning, "Unable to save click: #{inspect(changeset)}")
        IO.puts("Unable to save click: #{inspect(changeset)}")
        click_redirect(conn, campaign)

      {:error, :calc_rev_error} ->
        %Impression{campaign: %Campaign{} = campaign} =
          impression =
          Impressions.get_impression!(impression_id)
          |> CodeFund.Repo.preload([:campaign, [property: :user]])

        %{distribution_amount: _distribution_amount, revenue_amount: revenue_amount} =
          calculate_revenue(campaign, impression.property)

        save_click(conn, %{
          impression_id: impression_id,
          revenue_amount: revenue_amount,
          fraud_check_url: nil,
          distribution_amount: 0
        })

        click_redirect(conn, campaign)
    end
  end

  def improvely_inbound(conn, %{"campaign_id" => _campaign_id, "utm_content" => click_id}) do
    click = Clicks.get_click!(click_id) |> CodeFund.Repo.preload(:sponsorship)
    sponsorship = click.sponsorship

    revenue = Money.new(sponsorship.bid_amount, :USD)

    revenue_rate =
      if is_nil(sponsorship.override_revenue_rate) do
        sponsorship.property.user.revenue_rate
      else
        sponsorship.override_revenue_rate
      end

    distribution =
      case Money.mult(revenue, revenue_rate) do
        {:ok, amount} ->
          Money.round(amount).amount

        {:error, _} ->
          report(:warning)
          0
      end

    Clicks.set_status(click, :redirected, %{
      revenue_amount: revenue.amount,
      distribution_amount: distribution
    })

    uri = URI.parse(sponsorship.redirect_url)

    new_query =
      case uri.query do
        nil -> "?cs_id=#{click_id}"
        _ -> "#{uri.query}&cs_id=#{click_id}"
      end

    url = "#{uri.scheme}://#{uri.host}#{uri.path}?#{new_query}"
    Clicks.update_click(click, %{redirected_at: NaiveDateTime.utc_now(), redirected_to_url: url})
    redirect(conn, external: url)
  end

  defp browser_details(conn) do
    ip_address = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")

    referrer =
      (conn |> get_req_header("referer") |> Enum.at(0) || "") |> URI.parse() |> Map.get(:hostd)

    os = conn |> Browser.platform() |> to_string

    %{
      ip: ip_address,
      user_agent: Browser.Ua.to_ua(conn),
      referrer: referrer,
      os: os,
      is_bot: Browser.bot?(conn),
      device_type: parse_device_type(conn)
    }
  end

  defp calculate_revenue(campaign, property) do
    with %Money{} = revenue_amount <- Money.new(campaign.bid_amount, :USD),
         revenue_rate <- campaign.override_revenue_rate || property.user.revenue_rate,
         {:ok, %Money{} = distribution_amount} <- Money.mult(revenue_amount, revenue_rate),
         %Money{amount: rounded_revenue_sub_total} <- Money.round(distribution_amount) do
      %{
        revenue_amount: rounded_revenue_sub_total,
        distribution_amount: distribution_amount.amount
      }
    else
      _ ->
        report(:error, "could not calculate revenue on a campaign click")
        {:error, :calc_rev_error}
    end
  end

  defp click_redirect(conn, %Campaign{redirect_url: redirect_url}) do
    redirect(conn, external: redirect_url)
  end

  defp track_click(conn, impression_id, %Campaign{fraud_check_url: nil} = campaign, property) do
    report(
      :warning,
      "The campaign #{campaign.name} - #{campaign.id} does not have a fraud check url"
    )

    save_click(
      conn,
      %{impression_id: impression_id, fraud_check_url: nil}
      |> Map.merge(calculate_revenue(campaign, property))
    )
  end

  defp track_click(conn, impression_id, %Campaign{} = campaign, property) do
    click_attributes =
      calculate_revenue(campaign, property)
      |> Map.merge(%{
        impression_id: impression_id,
        fraud_check_redirected_at: Timex.now(),
        fraud_check_url: campaign.fraud_check_url
      })

    {:ok, %Click{id: click_id}} =
      save_click(
        conn,
        click_attributes
      )

    enqueue_worker_in(120, CodeFundWeb.VerifyClickRedirected, [click_id])
    redirect(conn, external: "#{click_attributes.fraud_check_url}?utm_content=#{click_id}")
  end

  defp save_click(conn, click_attributes) do
    browser_details = browser_details(conn)

    %{
      is_duplicate: Clicks.is_duplicate?(click_attributes.impression_id, browser_details.ip),
      landing_page: conn.request_path,
      browser: Browser.name(browser_details.user_agent)
    }
    |> Map.merge(%{status: CodeFund.Schema.Click.statuses()[:redirected]})
    |> Map.merge(click_attributes)
    |> Map.merge(browser_details)
    |> set_status_and_final_distributions
    |> Clicks.create_click()
  end

  defp set_status_and_final_distributions(click_attributes) do
    click_attributes =
      case click_attributes.is_bot || click_attributes.is_duplicate do
        true ->
          Map.merge(click_attributes, %{
            revenue_amount: Decimal.new(0),
            distribution_amount: Decimal.new(0)
          })

        false ->
          click_attributes
      end

    case click_attributes.fraud_check_url |> is_nil do
      true ->
        click_attributes

      false ->
        Map.merge(click_attributes, %{status: CodeFund.Schema.Click.statuses()[:fraud_check]})
    end
  end

  defp update_impression_with_browser_attributes(conn, impression_id) do
    Impressions.get_impression!(impression_id)
    |> Impressions.update_impression(browser_details(conn))
  end

  defp parse_device_type(conn) do
    cond do
      Browser.mobile?(conn) -> "mobile"
      Browser.tablet?(conn) -> "tablet"
      Browser.console?(conn) -> "console"
      Browser.known?(conn) -> "desktop"
      true -> "unknown"
    end
  end

  # # See https://github.com/akira/exq/issues/199
  defp enqueue_worker(worker, args) do
    if Mix.env() == :test do
      apply(worker, :perform, args)
    else
      Exq.enqueue(Exq, "cs_low", worker, args)
    end
  end

  defp enqueue_worker_in(duration, worker, args) do
    if Mix.env() == :test do
      spawn(fn ->
        :timer.sleep(duration + 30)
        apply(worker, :perform, args)
      end)
    else
      Exq.enqueue_in(Exq, "cs_low", duration, worker, args)
    end
  end
end
