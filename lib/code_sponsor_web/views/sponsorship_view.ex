defmodule CodeSponsorWeb.SponsorshipView do
  use CodeSponsorWeb, :view

  import CodeSponsorWeb.TableView

  def title(:index), do: "Code Sponsor | My Sponsorships"
  def title(:new),   do: "Code Sponsor | Add Sponsorship"
  def title(:edit),  do: "Code Sponsor | Edit Sponsorship"
  def title(:show),  do: "Code Sponsor | View Sponsorship"
end
