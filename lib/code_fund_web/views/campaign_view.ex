defmodule CodeFundWeb.CampaignView do
  use CodeFundWeb, :view

  import CodeFundWeb.TableView
  alias CodeFund.Schema.Campaign
  alias CodeFund.Campaigns

  def has_remaining_budget?(%Campaign{} = campaign) do
    case Campaigns.has_remaining_budget?(campaign) do
      true -> content_tag(:span, "Yes", class: "badge badge-success")
      false -> content_tag(:span, "No", class: "badge badge-light")
    end
  end
end
