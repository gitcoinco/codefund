defmodule CodeFundWeb.TemplateView do
  use CodeFundWeb, :view

  import CodeFundWeb.TableView

  def title(:index), do: "CodeFund | Templates"
  def title(:new), do: "CodeFund | Add Template"
  def title(:edit), do: "CodeFund | Edit Template"
  def title(:show), do: "CodeFund | View Template"
end
