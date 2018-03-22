defmodule CodeSponsorWeb.TemplateView do
  use CodeSponsorWeb, :view

  import CodeSponsorWeb.TableView

  def title(:index), do: "Code Sponsor | Templates"
  def title(:new),   do: "Code Sponsor | Add Template"
  def title(:edit),  do: "Code Sponsor | Edit Template"
  def title(:show),  do: "Code Sponsor | View Template"
end
