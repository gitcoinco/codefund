defmodule CodeFundWeb.API.AdServeView do
  use CodeFundWeb, :view

  def render("details.json", %{payload: payload}) do
    payload
  end

  def strip_white_space(nil), do: nil

  def strip_white_space(body) do
    body
    |> String.replace(~r/\r|\n/, "")
  end
end
