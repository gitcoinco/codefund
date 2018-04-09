defmodule CodeFundWeb.PageController do
  use CodeFundWeb, :controller

  def index(conn, _params) do
    conn = put_layout(conn, false)

    stats = %{
      impression_count: CodeFund.Repo.aggregate(CodeFund.Schema.Impression, :count, :id),
      click_count: CodeFund.Repo.aggregate(CodeFund.Schema.Click, :count, :id),
      property_count: CodeFund.Repo.aggregate(CodeFund.Schema.Property, :count, :id),
      funding_total: 1333.25
    }

    render(conn, "index.html", stats: stats)
  end
end
