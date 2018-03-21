defmodule CodeSponsorWeb.ThemeView do
  use CodeSponsorWeb, :view

  import CodeSponsorWeb.TableView

  def title(:index), do: "Code Sponsor | Themes"
  def title(:new),   do: "Code Sponsor | Add Theme"
  def title(:edit),  do: "Code Sponsor | Edit Theme"
  def title(:show),  do: "Code Sponsor | View Theme"
end
