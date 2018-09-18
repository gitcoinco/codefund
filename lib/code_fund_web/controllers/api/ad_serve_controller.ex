defmodule CodeFundWeb.API.AdServeController do
  use CodeFundWeb, :controller

  alias CodeFund.{Templates, Themes}
  alias CodeFund.Schema.{Theme, Template}

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

  @spec details(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def details(conn, %{"property_id" => property_id} = params) do
    conn
    |> AdService.Server.serve(property_id, params)
    |> details_render(conn)
  end

  defp details_render(payload, conn), do: render(conn, "details.json", payload: payload)

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
end
