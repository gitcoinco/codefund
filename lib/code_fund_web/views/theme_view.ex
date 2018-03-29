defmodule CodeFundWeb.ThemeView do
  use CodeFundWeb, :view

  import CodeFundWeb.TableView

  def title(:index), do: "CodeFund | Themes"
  def title(:new), do: "CodeFund | Add Theme"
  def title(:edit), do: "CodeFund | Edit Theme"
  def title(:show), do: "CodeFund | View Theme"
end
