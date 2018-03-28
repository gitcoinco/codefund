defmodule CodeFundWeb.DashboardView do
  use CodeFundWeb, :view

  def pretty_date_range(start_date, end_date) do
    {:ok, formatted_start_date} = start_date |> Timex.format("%b %d, %Y", :strftime)
    {:ok, formatted_end_date}   = end_date   |> Timex.format("%b %d, %Y", :strftime)
    "#{formatted_start_date} to #{formatted_end_date}"
  end
end
