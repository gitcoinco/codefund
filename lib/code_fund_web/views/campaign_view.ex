defmodule CodeFundWeb.CampaignView do
  use CodeFundWeb, :view

  import CodeFundWeb.TableView
  alias CodeFund.Schema.Campaign
  alias CodeFund.Campaigns

  def title(:index), do: "CodeFund | My Campaigns"
  def title(:new),   do: "CodeFund | Add Campaign"
  def title(:edit),  do: "CodeFund | Edit Campaign"
  def title(:show),  do: "CodeFund | View Campaign"

  def has_remaining_budget?(%Campaign{} = campaign) do
    case Campaigns.has_remaining_budget?(campaign) do
      true -> content_tag(:span, "Yes", class: "badge badge-success")
      false -> content_tag(:span, "No", class: "badge badge-light")
    end
  end
end
