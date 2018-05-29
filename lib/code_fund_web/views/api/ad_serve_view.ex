defmodule CodeFundWeb.API.AdServeView do
  use CodeFundWeb, :view

  def render("details.json", %{payload: payload}) do
    payload
  end
end
