defmodule CodeSponsorWeb.AdServeView do
  use CodeSponsorWeb, :view

  def render("details.json", %{payload: payload}) do
    payload
  end
end
