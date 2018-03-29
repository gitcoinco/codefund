defmodule CodeFundWeb.Coherence.RegistrationView do
  use CodeFundWeb.Coherence, :view

  def title(:new), do: "CodeFund | Register"
  def body_class(_), do: "app flex-row align-items-center"
end
