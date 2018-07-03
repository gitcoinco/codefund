defmodule CodeFundWeb.TrackController do
  use CodeFundWeb, :controller
  alias CodeFund.Impressions
  alias CodeFund.Schema.Campaign
  alias CodeFund.Schema.Property

  @transparent_png <<71, 73, 70, 56, 57, 97, 1, 0, 1, 0, 128, 0, 0, 0, 0, 0, 255, 255, 255, 33,
                     249, 4, 1, 0, 0, 0, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 1, 68, 0, 59>>

  def pixel(conn, %{"impression_id" => impression_id}) do
    with %CodeFund.Schema.Impression{} = impression <- Impressions.get_impression!(impression_id),
         {:ok, location_information} <- Framework.Geolocation.find_by_ip(conn.remote_ip, :city),
         update_details <- Framework.Browser.details(conn) |> Map.merge(location_information),
         {:ok, %CodeFund.Schema.Impression{id: ^impression_id}} <-
           impression |> Impressions.update_impression(update_details) do
      conn
      |> put_resp_content_type("image/png")
      |> send_resp(200, @transparent_png)
    else
      {:error, _} ->
        conn
    end
  end

  def click(conn, %{"impression_id" => impression_id}) do
    impression =
      impression_id
      |> Impressions.get_impression!()
      |> CodeFund.Repo.preload([:campaign, :property])

    update_attributes = %{
      redirected_to_url: construct_redirected_to_url(impression.campaign, impression.property),
      redirected_at: Timex.now()
    }

    {:ok, _impression} =
      impression
      |> Impressions.update_impression(update_attributes)

    redirect(conn, external: update_attributes.redirected_to_url)
  end

  defp construct_redirected_to_url(%Campaign{redirect_url: redirect_url}, %Property{slug: slug}) do
    uri_struct =
      redirect_url
      |> URI.parse()

    utm_term_query_string =
      uri_struct
      |> build_query_string(slug)

    uri_struct
    |> Map.put(:query, utm_term_query_string)
    |> to_string
  end

  defp build_query_string(%URI{query: nil}, slug) do
    %{"utm_term" => slug}
    |> URI.encode_query()
  end

  defp build_query_string(%URI{query: query}, slug) do
    query
    |> URI.decode_query()
    |> Map.put("utm_term", slug)
    |> URI.encode_query()
  end
end
