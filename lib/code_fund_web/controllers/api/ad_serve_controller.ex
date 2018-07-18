defmodule CodeFundWeb.API.AdServeController do
  use CodeFundWeb, :controller

  alias CodeFund.{Campaigns, Impressions, Properties, Templates, Themes}
  alias CodeFund.Schema.{Campaign, Impression, Property, Theme, Template}

  def embed(conn, %{"property_id" => property_id} = params) do
    template_slug = params["template"] || "default"
    theme_slug = params["theme"] || "light"
    targetId = params["target"] || "codefund_ad"

    with %Theme{template: %Template{}} = theme <-
           Themes.get_template_or_theme_by_slugs(theme_slug, template_slug),
         details_url <- "https://#{conn.host}/t/s/#{property_id}/details.json" do
      conn
      |> put_resp_content_type("application/javascript")
      |> render(
        "embed.js",
        template: theme.template,
        targetId: targetId,
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

  def details(conn, %{"property_id" => property_id}) do
    with %Property{
           status: 1,
           user: property_owner,
           audience: audience
         }
         when not is_nil(audience) <-
           Properties.get_property!(property_id) |> CodeFund.Repo.preload([:user, :audience]),
         {:ok, client_country} <- Framework.Geolocation.find_by_ip(conn.remote_ip, :country),
         {:ok, ad_tuple} <-
           AdService.Query.ForDisplay.build(audience, client_country)
           |> CodeFund.Repo.all()
           |> AdService.Display.choose_winner(),
         %AdService.Advertisement{
           image_url: image_url,
           body: body,
           campaign_id: campaign_id,
           headline: headline
         } <- ad_tuple |> AdService.Display.render(),
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
          revenue_amount: AdService.Math.CPM.revenue_amount(campaign),
          distribution_amount: AdService.Math.CPM.distribution_amount(campaign, property_owner)
        })

      %{
        image: image_url,
        link: "https://#{conn.host}/c/#{impression_id}",
        description: body,
        pixel: "//#{conn.host}/p/#{impression_id}/pixel.png",
        poweredByLink: "https://codefund.io?utm_content=#{campaign_id}",
        headline: headline
      }
      |> details_render(conn)
    else
      %Property{} ->
        conn
        |> error_details(property_id, "This property is not currently active")
        |> details_render(conn)

      {:error, _reason} ->
        conn
        |> error_details(property_id, "CodeFund does not have an advertiser for you at this time")
        |> details_render(conn)
    end
  end

  defp details_render(payload, conn), do: render(conn, "details.json", payload: payload)

  defp error_details(conn, property_id, reason) do
    {:ok, %Impression{id: impression_id}} =
      Impressions.create_impression(%{
        property_id: property_id,
        campaign_id: nil,
        ip: conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
      })

    %{
      image: "",
      link: "",
      headline: "",
      description: "",
      pixel: "//#{conn.host}/p/#{impression_id}/pixel.png",
      poweredByLink: "https://codefund.io?utm_content=",
      reason: reason
    }
  end
end
