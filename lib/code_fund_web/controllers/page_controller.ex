defmodule CodeFundWeb.PageController do
  use CodeFundWeb, :controller

  def index(conn, _params) do
    conn = put_layout(conn, false)
    render(conn, "index.html")
  end
end
