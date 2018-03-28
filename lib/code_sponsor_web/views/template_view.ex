defmodule CodeSponsorWeb.TemplateView do
  use CodeSponsorWeb, :view

  import CodeSponsorWeb.TableView

  def title(:index), do: "CodeFund | Templates"
  def title(:new),   do: "CodeFund | Add Template"
  def title(:edit),  do: "CodeFund | Edit Template"
  def title(:show),  do: "CodeFund | View Template"
end
