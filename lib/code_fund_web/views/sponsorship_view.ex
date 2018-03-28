defmodule CodeFundWeb.SponsorshipView do
  use CodeFundWeb, :view

  import CodeFundWeb.TableView

  def title(:index), do: "CodeFund | My Sponsorships"
  def title(:new),   do: "CodeFund | Add Sponsorship"
  def title(:edit),  do: "CodeFund | Edit Sponsorship"
  def title(:show),  do: "CodeFund | View Sponsorship"
end
