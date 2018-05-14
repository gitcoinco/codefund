defmodule CodeFundWeb.AdServeController do
  use CodeFundWeb, :controller

  alias CodeFund.{Properties, Sponsorships, Templates, Themes}
  alias CodeFund.Schema.{Property, Sponsorship, Campaign, Creative, Theme, Template}

  def embed(conn, %{"property_id" => property_id} = params) do
    template_slug = params["template"] || "default"
    theme_slug = params["theme"] || "light"
    targetId = params["target"] || "codefund_ad"

    # TODO: refactor this into two different methods, and use if is_nil(template) to invoke the correct one
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
    with false <- Framework.Geolocation.is_banned_country?(conn.remote_ip),
         %Property{status: 1} = property <- Properties.get_property!(property_id),
         %Sponsorship{creative: %Creative{}, campaign: %Campaign{}} = sponsorship <-
           Sponsorships.get_sponsorship_for_property(property) do
      %{
        image: sponsorship.creative.image_url,
        link: "https://#{conn.host}/t/s/#{sponsorship.id}",
        headline: sponsorship.creative.headline,
        description: sponsorship.creative.body,
        pixel: "//#{conn.host}/t/p/#{sponsorship.id}/pixel.png",
        poweredByLink: "https://codefund.io?utm_content=#{sponsorship.id}"
      }
      |> details_render(conn)
    else
      %Property{} ->
        conn
        |> error_details(property_id, "This property is not currently active")
        |> details_render(conn)

      %Sponsorship{creative: nil} ->
        conn
        |> error_details(
          property_id,
          "CodeFund creative has not been assigned to the sponsorship"
        )
        |> details_render(conn)

      true ->
        conn
        |> error_details(property_id, "CodeFund does not have an advertiser for you at this time")
        |> details_render(conn)

      nil ->
        conn
        |> error_details(property_id, "CodeFund does not have an advertiser for you at this time")
        |> details_render(conn)
    end
  end

  defp details_render(payload, conn), do: render(conn, "details.json", payload: payload)

  defp error_details(conn, property_id, reason) do
    %{
      image: "",
      link: "",
      headline: "",
      description: "",
      pixel: "//#{conn.host}/t/l/#{property_id}/pixel.png",
      poweredByLink: "https://codefund.io?utm_content=",
      reason: reason
    }
  end
end
