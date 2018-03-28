defmodule CodeFundWeb.DashboardController do
  use CodeFundWeb, :controller

  def index(conn, _params) do
    current_user = conn.assigns.current_user
    end_date     = ~D[2018-03-31]
    start_date   = ~D[2018-03-01]

    impressions_by_day = CodeFund.Stats.Impressions.count_by_day(current_user, start_date, end_date)
    clicks_by_day      = CodeFund.Stats.Clicks.count_by_day(current_user, start_date, end_date)
    total_impressions  = Enum.map(impressions_by_day, fn {_, v} -> v end) |> Enum.sum
    total_clicks       = Enum.map(clicks_by_day, fn {_, v} -> v end) |> Enum.sum

    render(conn, "index.html",
      start_date: start_date,
      end_date: end_date,
      impressions_by_day: Poison.encode!(impressions_by_day),
      clicks_by_day: Poison.encode!(clicks_by_day),
      total_impressions: total_impressions,
      total_clicks: total_clicks)
  end
end