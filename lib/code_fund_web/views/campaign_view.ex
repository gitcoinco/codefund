defmodule CodeFundWeb.CampaignView do
  use CodeFundWeb, :view

  import CodeFundWeb.TableView
  # import CodeFundWeb.FilterView

  def title(:index), do: "CodeFund | My Campaigns"
  def title(:new),   do: "CodeFund | Add Campaign"
  def title(:edit),  do: "CodeFund | Edit Campaign"
  def title(:show),  do: "CodeFund | View Campaign"
end
