defmodule CodeFundWeb.API.AdServeController do
  use CodeFundWeb, :controller

  alias AdService.Advertisement
  alias CodeFund.{Campaigns, Impressions, Properties, Templates, Themes}
  alias CodeFund.Schema.{Campaign, Impression, Property, Theme, Template}

  def embed(conn, %{"property_id" => property_id} = params) do
    template_slug = Templates.slug_for_property_id(property_id, params["template"])
    theme_slug = params["theme"] || "light"
    target_id = params["target"] || "codefund_ad"

    with %Theme{template: %Template{}} = theme <-
           Themes.get_template_or_theme_by_slugs(theme_slug, template_slug),
         details_url <- "https://#{conn.host}/t/s/#{property_id}/details.json" do
      conn
      |> put_resp_content_type("application/javascript")
      |> render(
        "embed.js",
        template: theme.template,
        targetId: target_id,
        theme: theme,
        details_url: details_url
      )
    else
      %Template{} = template ->
        error_render(conn, "theme", Themes.list_themes_for_template(template))

      nil ->
        error_render(conn, "template", Templates.list_templates())
    end
  end

  defp error_render(conn, object_type, list_of_objects) do
    conn
    |> put_status(:not_found)
    |> put_resp_content_type("application/javascript")
    |> text(
      "console.log('CodeFund #{object_type} does not exist. Available #{object_type}s are [#{
        list_of_objects |> Enum.map(fn object -> Map.get(object, :slug) end) |> Enum.join("|")
      }]');"
    )
  end

  def details(conn, %{"property_id" => property_id} = params) do
    with {:error, :no_cache_found} <-
           AdService.ImpressionCache.lookup(conn.remote_ip, property_id),
         {:ok, client_country} <- Framework.Geolocation.find_by_ip(conn.remote_ip, :country),
         %Property{
           status: 1,
           user: property_owner,
           audience: audience,
           excluded_advertisers: excluded_advertisers
         }
         when not is_nil(audience) <-
           Properties.get_property!(property_id) |> CodeFund.Repo.preload([:user, :audience]),
         :ok <- Framework.Browser.certify_human(conn),
         {:ok, ad_tuple} <-
           AdService.Query.ForDisplay.build(audience, client_country, excluded_advertisers)
           |> CodeFund.Repo.all()
           |> AdService.Display.choose_winner(),
         %Advertisement{campaign_id: campaign_id} = advertisement <-
           ad_tuple |> AdService.Display.render(),
         %Campaign{} = campaign <- Campaigns.get_campaign!(campaign_id),
         {:ok, _} <-
           AdService.CampaignImpressionManager.can_create_impression?(
             campaign_id,
             campaign.impression_count
           ) do
      {:ok, %Impression{id: impression_id}} =
        Impressions.create_impression(%{
          ip: conn.remote_ip |> Tuple.to_list() |> Enum.join("."),
          property_id: property_id,
          campaign_id: campaign_id,
          country: client_country,
          revenue_amount: AdService.Math.CPM.revenue_amount(campaign),
          distribution_amount: AdService.Math.CPM.distribution_amount(campaign, property_owner),
          browser_height: params["height"] || "",
          browser_width: params["width"] || ""
        })

      payload = payload(advertisement, conn, impression_id)

      {:ok, :cache_stored} =
        payload
        |> AdService.ImpressionCache.store(conn.remote_ip, conn.params["property_id"])

      payload
      |> details_render(conn)
    else
      {:ok, :cache_loaded, details} ->
        details |> details_render(conn)

      %Property{} ->
        conn
        |> create_impression_with_error(
          property_id,
          "This property is not currently active - code: #{
            AdService.ImpressionErrors.fetch_code(:property_inactive)
          }",
          :property_inactive,
          params["height"] || "",
          params["width"] || ""
        )
        |> details_render(conn)

      {:error, :is_bot} ->
        error_map("CodeFund does not have an advertiser for you at this time")
        |> details_render(conn)

      {:error, reason_atom} ->
        conn
        |> create_impression_with_error(
          property_id,
          "CodeFund does not have an advertiser for you at this time - code: #{
            AdService.ImpressionErrors.fetch_code(reason_atom)
          }",
          reason_atom,
          params["height"] || "",
          params["width"] || ""
        )
        |> details_render(conn)
    end
  end

  defp details_render(payload, conn), do: render(conn, "details.json", payload: payload)

  defp payload(
         %Advertisement{
           image_url: image_url,
           body: body,
           campaign_id: campaign_id,
           headline: headline,
           small_image_object: small_image_object,
           large_image_object: large_image_object
         },
         conn,
         impression_id
       ) do
    %{
      image: image_url,
      small_image_url: Framework.FileStorage.url(small_image_object),
      large_image_url: Framework.FileStorage.url(large_image_object),
      link: "https://#{conn.host}/c/#{impression_id}",
      description: body,
      pixel: "//#{conn.host}/p/#{impression_id}/pixel.png",
      poweredByLink: "https://codefund.io?utm_content=#{campaign_id}",
      headline: headline
    }
  end

  defp create_impression_with_error(
         conn,
         property_id,
         reason_message,
         :no_possible_ads,
         height,
         width
       ) do
    params = %{
      property_id: property_id,
      error_code: AdService.ImpressionErrors.fetch_code(:no_possible_ads),
      ip: conn.remote_ip |> Tuple.to_list() |> Enum.join("."),
      browser_height: height,
      browser_width: width,
      country: conn.remote_ip |> parse_country
    }

    case property_id |> AdService.Query.ForDisplay.fallback_ad_by_property_id() do
      %Advertisement{} = advertisement ->
        {:ok, %Impression{id: impression_id}} =
          params
          |> Map.merge(%{campaign_id: advertisement.campaign_id, house_ad: true})
          |> Impressions.create_impression()

        advertisement
        |> payload(conn, impression_id)

      nil ->
        {:ok, %Impression{id: impression_id}} =
          params
          |> Impressions.create_impression()

        error_map(reason_message, "//#{conn.host}/p/#{impression_id}/pixel.png")
    end
  end

  defp create_impression_with_error(conn, property_id, reason_message, reason_atom, height, width) do
    {:ok, %Impression{id: impression_id}} =
      Impressions.create_impression(%{
        property_id: property_id,
        campaign_id: nil,
        country: conn.remote_ip |> parse_country,
        error_code: AdService.ImpressionErrors.fetch_code(reason_atom),
        ip: conn.remote_ip |> Tuple.to_list() |> Enum.join("."),
        browser_height: height,
        browser_width: width
      })

    error_map(reason_message, "//#{conn.host}/p/#{impression_id}/pixel.png")
  end

  defp parse_country(ip) do
    {:ok, client_country} = Framework.Geolocation.find_by_ip(ip, :country)
    client_country
  end

  defp error_map(reason_message, pixel_url \\ "") do
    %{
      image: "",
      link: "",
      headline: "",
      description: "",
      pixel: pixel_url,
      poweredByLink: "https://codefund.io?utm_content=",
      reason: reason_message
    }
  end
end
