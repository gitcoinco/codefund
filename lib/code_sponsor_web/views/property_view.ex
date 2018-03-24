defmodule CodeSponsorWeb.PropertyView do
  use CodeSponsorWeb, :view

  import CodeSponsorWeb.TableView
  # import CodeSponsorWeb.FilterView

  def title(:index), do: "Code Sponsor | My Properties"
  def title(:new),   do: "Code Sponsor | Add Property"
  def title(:edit),  do: "Code Sponsor | Edit Property"
  def title(:show),  do: "Code Sponsor | View Property"

  def body_class(_), do: "app flex-row align-items-center"

  def favicon_image_url(url) do
    domain = String.replace(url, ~r/^https?:\/\//, "")
    "//www.google.com/s2/favicons?domain=#{domain}"
  end

  def script_embed_code(conn, %CodeSponsor.Schema.Property{} = property) do
    url = "https://#{conn.host}/scripts/#{property.id}/embed.js"
    '''
    <script src="#{url}"></script>
    <div id="codefund_ad"></div>
    '''
  end
end
