defmodule CodeFundWeb.API.User.CreativeController do
  use CodeFundWeb, :controller

  def index(conn, %{"user_id" => user_id}) do
    creatives =
      CodeFund.Creatives.by_user_id(user_id)
      |> Enum.map(fn creative -> %{name: creative.name, id: creative.id} end)

    conn
    |> json(%{creatives: creatives})
  end
end
