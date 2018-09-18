defmodule CodeFundWeb.Coherence.RegistrationView do
  use CodeFundWeb.Coherence, :view
  import CodeFundWeb.ViewHelpers, only: [has_any_role?: 2]

  def title(:new), do: "CodeFund | Register"
  def body_class(_), do: "app flex-row align-items-center"
end
