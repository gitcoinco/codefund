defmodule CodeSponsorWeb.Coherence.SessionView do
  use CodeSponsorWeb.Coherence, :view
  
  def title(:new), do: "Code Sponsor | Login"
  def body_class(_), do: "app flex-row align-items-center"
end
