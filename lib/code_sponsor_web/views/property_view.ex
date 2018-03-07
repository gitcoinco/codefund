defmodule CodeSponsorWeb.PropertyView do
  use CodeSponsorWeb, :view

  import CodeSponsorWeb.TableView
  import CodeSponsorWeb.FilterView

  def title(:index), do: "Code Sponsor | My Properties"
  def title(:new),   do: "Code Sponsor | Add Property"
  def title(:edit),  do: "Code Sponsor | Edit Property"
  def title(:show),  do: "Code Sponsor | View Property"

  def body_class(_), do: "app flex-row align-items-center"

  def favicon_image_url(url) do
    domain = String.replace(url, ~r/^https?:\/\//, "")
    "//www.google.com/s2/favicons?domain=#{domain}"
  end
end
