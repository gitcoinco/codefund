defmodule CodeSponsorWeb.DashboardController do
  use CodeSponsorWeb, :controller
  alias CodeSponsor.Stats

  def index(conn, _params) do
    current_user = conn.assigns.current_user
    
    start_date = ~D[2018-03-01]
    end_date = ~D[2018-03-31]

    clicks_by_day = 
      Stats.Clicks.count_by_day(current_user, start_date, end_date)
      |> Poison.encode!

    impressions_by_day = 
      Stats.Impressions.count_by_day(current_user, start_date, end_date)
      |> Poison.encode!

    render(conn, "index.html",
      start_date: start_date,
      end_date: end_date,
      clicks_by_day: clicks_by_day,
      impressions_by_day: impressions_by_day
    )
  end
end