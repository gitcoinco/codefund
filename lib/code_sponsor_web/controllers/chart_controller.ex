defmodule CodeSponsorWeb.ChartController do
  use CodeSponsorWeb, :controller

  def traffic_impressions(conn, _params) do
    end_date = Timex.now
    start_date = Timex.shift(end_date, days: -7)
    
    render(conn, "traffic_impressions.html",
      start_date: start_date,
      end_date: end_date
    )
  end
end