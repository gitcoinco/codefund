defmodule CodeFundWeb.TrackController do
  use CodeFundWeb, :controller
  import Framework.Worker
  alias CodeFund.Impressions

  @transparent_png <<71, 73, 70, 56, 57, 97, 1, 0, 1, 0, 128, 0, 0, 0, 0, 0, 255, 255, 255, 33,
                     249, 4, 1, 0, 0, 0, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 1, 68, 0, 59>>

  def pixel(conn, %{"impression_id" => impression_id}) do
    with %CodeFund.Schema.Impression{} = impression <- Impressions.get_impression!(impression_id),
         {:ok, %CodeFund.Schema.Impression{id: impression_id}} <-
           impression |> Impressions.update_impression(Framework.Browser.details(conn)),
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
    impression =
      impression_id
      |> Impressions.get_impression!()
      |> CodeFund.Repo.preload(:campaign)

    update_attributes = %{
      redirected_to_url: impression.campaign.redirect_url,
      redirected_at: Timex.now()
    }

    {:ok, impression} =
      impression
      |> Impressions.update_impression(update_attributes)

    redirect(conn, external: impression.campaign.redirect_url)
  end
end
