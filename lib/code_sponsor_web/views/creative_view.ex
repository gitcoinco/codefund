defmodule CodeSponsorWeb.CreativeView do
  use CodeSponsorWeb, :view

  import CodeSponsorWeb.TableView

  def title(:index), do: "Code Sponsor | Creatives"
  def title(:new),   do: "Code Sponsor | Add Creative"
  def title(:edit),  do: "Code Sponsor | Edit Creative"
  def title(:show),  do: "Code Sponsor | View Creative"
end
