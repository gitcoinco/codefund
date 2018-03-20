defmodule CodeSponsorWeb.AdServeController do
  use CodeSponsorWeb, :controller

  alias CodeSponsor.{Properties, Sponsorships, Creatives}

  def embed(conn, %{"property_id" => property_id} = params) do
    property    = Properties.get_property!(property_id)
    sponsorship = Sponsorships.get_sponsorship_for_property(property)
    templates   = Creatives.list_templates()
    themes      = Creatives.list_themes()

    template = params["template"] || "default"
    theme = params["theme"] || "light"
    targetId = params["target"] || "codefund_ad"

    conn
    |> put_resp_content_type("application/javascript")
    |> render "embed.js",
              property: property,
              sponsorship: sponsorship,
              template: template,
              theme: theme,
              targetId: targetId,
              templates: templates,
              themes: themes
  end

  def details(conn, %{"property_id" => property_id} = params) do
    # NOTE: Track Impression Here
    
    property = Properties.get_property!(property_id)
    sponsorship = Sponsorships.get_sponsorship_for_property(property)

    payload = %{
      image: "//example.com/image.png",
      link: "//example.com",
      description: "lorem ipsum dolor",
      pixel: "//example.com/pixel.png"
    }

    render conn, "details.json", payload: payload
  end
end