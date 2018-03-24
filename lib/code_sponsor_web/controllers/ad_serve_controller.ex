defmodule CodeSponsorWeb.AdServeController do
  use CodeSponsorWeb, :controller

  alias CodeSponsor.{Properties, Sponsorships, Creatives}

  def embed(conn, %{"property_id" => property_id} = params) do
    property      = Properties.get_property!(property_id)
    template_slug = params["template"] || "default"
    theme_slug    = params["theme"] || "light"
    template      = Creatives.get_template_by_slug(template_slug)
    targetId      = params["target"] || "codefund_ad"

    cond do
      template == nil ->
        templates = Creatives.list_templates()
        template_slugs = Enum.map(templates, fn (c) -> c.slug end)

        conn
        |> put_status(:not_found)
        |> put_resp_content_type("application/javascript")
        |> text("console.log('CodeFund template does not exist. Available templates are \\'#{Enum.join(template_slugs, "','")}\\'');")

      true ->
        theme = Enum.find(template.themes, fn(t) -> t.slug == theme_slug end)
        cond do
          theme == nil ->
            themes = Creatives.list_themes()
            theme_slugs = Enum.map(themes, fn (c) -> c.slug end)

            conn
            |> put_resp_content_type("application/javascript")
            |> text("console.log('CodeFund theme does not exist. Available themes for this template are \\'#{Enum.join(theme_slugs, "','")}\\'');")

          true ->
            details_url = "//#{conn.host}/t/s/#{property.id}/details.json"
            conn
            |> put_resp_content_type("application/javascript")
            |> render("embed.js",
                      property: property,
                      template: template,
                      targetId: targetId,
                      theme: theme,
                      template: template,
                      details_url: details_url)
        end
    end
  end

  def details(conn, %{"property_id" => property_id}) do
    property    = Properties.get_property!(property_id)
    sponsorship = Sponsorships.get_sponsorship_for_property(property)
    creative    = sponsorship.creative

    payload = cond do
      sponsorship == nil || creative == nil ->
        %{
          image: "",
          link: "",
          description: "",
          pixel: "//#{conn.host}/t/l/#{property.id}/pixel.png",
          poweredByLink: "https://codefund.io?utm_content="
        }
      true ->
        %{
          image: creative.image_url,
          link: "https://#{conn.host}/t/s/#{sponsorship.id}",
          description: creative.body,
          pixel: "//#{conn.host}/t/l/#{property.id}/pixel.png",
          poweredByLink: "https://codefund.io?utm_content=#{sponsorship.id}"
        }
    end

    render conn, "details.json", payload: payload
  end
end
