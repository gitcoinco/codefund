defmodule CodeSponsorWeb.ThemeView do
  use CodeSponsorWeb, :view

  import CodeSponsorWeb.TableView

  def title(:index), do: "CodeFund | Themes"
  def title(:new),   do: "CodeFund | Add Theme"
  def title(:edit),  do: "CodeFund | Edit Theme"
  def title(:show),  do: "CodeFund | View Theme"
end
