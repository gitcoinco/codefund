defmodule CodeSponsorWeb.CampaignView do
  use CodeSponsorWeb, :view

  import CodeSponsorWeb.TableView
  import CodeSponsorWeb.FilterView

  def title(:index), do: "Code Sponsor | My Campaigns"
  def title(:new),   do: "Code Sponsor | Add Campaign"
  def title(:edit),  do: "Code Sponsor | Edit Campaign"
  def title(:show),  do: "Code Sponsor | View Campaign"
end
