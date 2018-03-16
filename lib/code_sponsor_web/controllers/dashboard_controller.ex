defmodule CodeSponsorWeb.DashboardController do
  use CodeSponsorWeb, :controller

  def index(conn, _params) do
    current_user = conn.assigns.current_user
    end_date     = ~D[2018-03-31]
    start_date   = ~D[2018-03-01]

    impressions_by_day = 
      CodeSponsor.Stats.Impressions.count_by_day(current_user, start_date, end_date)
      |> Poison.encode!

    clicks_by_day =
      CodeSponsor.Stats.Clicks.count_by_day(current_user, start_date, end_date)
      |> Poison.encode!

    render(conn, "index.html",
      start_date: start_date,
      end_date: end_date,
      impressions_by_day: impressions_by_day,
      clicks_by_day: clicks_by_day)
  end
end