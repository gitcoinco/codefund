defmodule CodeSponsorWeb.CampaignView do
  use CodeSponsorWeb, :view

  import CodeSponsorWeb.TableView
  # import CodeSponsorWeb.FilterView

  def title(:index), do: "CodeFund | My Campaigns"
  def title(:new),   do: "CodeFund | Add Campaign"
  def title(:edit),  do: "CodeFund | Edit Campaign"
  def title(:show),  do: "CodeFund | View Campaign"
end
