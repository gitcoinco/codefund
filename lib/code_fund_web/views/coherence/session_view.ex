defmodule CodeFundWeb.Coherence.SessionView do
  use CodeFundWeb.Coherence, :view

  def title(:new), do: "CodeFund | Login"
  def body_class(_), do: "app align-items-center"
end
