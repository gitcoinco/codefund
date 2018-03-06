defmodule CodeSponsorWeb.PropertyView do
  use CodeSponsorWeb, :view

  import CodeSponsorWeb.TableView
  import CodeSponsorWeb.FilterView

  def favicon_image_url(url) do
    domain = String.replace(url, ~r/^https?:\/\//, "")
    "//www.google.com/s2/favicons?domain=#{domain}"
  end
end
