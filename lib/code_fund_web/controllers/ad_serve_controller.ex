defmodule CodeFundWeb.AdServeController do
  use CodeFundWeb, :controller

  alias CodeFund.{Properties, Sponsorships, Templates, Themes}
  alias CodeFund.Schema.{Property, Sponsorship, Campaign, Creative}

  def embed(conn, %{"property_id" => property_id} = params) do
    property = Properties.get_property!(property_id)
    template_slug = params["template"] || "default"
    theme_slug = params["theme"] || "light"
    template = Templates.get_template_by_slug(template_slug)
    targetId = params["target"] || "codefund_ad"

    # TODO: refactor this into two different methods, and use if is_nil(template) to invoke the correct one
    cond do
      template == nil ->
        templates = Templates.list_templates()

        available_templates =
          Enum.map(templates, fn c -> c.slug end)
          |> Enum.join("|")

        conn
        |> put_status(:not_found)
        |> put_resp_content_type("application/javascript")
        |> text(
          "console.log('CodeFund template does not exist. Available templates are [#{
            available_templates
          }]');"
        )

      true ->
        theme = Enum.find(template.themes, fn t -> t.slug == theme_slug end)

        cond do
          theme == nil ->
            themes = Themes.list_themes_for_template(template)
            available_slugs = Enum.map(themes, fn c -> c.slug end) |> Enum.join("|")

            conn
            |> put_status(:not_found)
            |> put_resp_content_type("application/javascript")
            |> text(
              "console.log('CodeFund theme does not exist. Available themes for this template are [#{
                available_slugs
              }]');"
            )

          true ->
            details_url = "https://#{conn.host}/t/s/#{property.id}/details.json"

            conn
            |> put_resp_content_type("application/javascript")
            |> render(
              "embed.js",
              property: property,
              template: template,
              targetId: targetId,
              theme: theme,
              template: template,
              details_url: details_url
            )
        end
    end
  end

  def details(conn, %{"property_id" => property_id}) do
    with %Property{status: 1} = property <- Properties.get_property!(property_id),
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
      head: "",
      description: "",
      pixel: "//#{conn.host}/t/l/#{property_id}/pixel.png",
      poweredByLink: "https://codefund.io?utm_content=",
      reason: reason
    }
  end
end
