defmodule CodeFundWeb.PropertyView do
  use CodeFundWeb, :view

  import CodeFundWeb.TableView
  # import CodeFundWeb.FilterView

  def title(:index), do: "CodeFund | My Properties"
  def title(:new),   do: "CodeFund | Add Property"
  def title(:edit),  do: "CodeFund | Edit Property"
  def title(:show),  do: "CodeFund | View Property"

  def body_class(_), do: "app flex-row align-items-center"

  def favicon_image_url(url) do
    domain = String.replace(url, ~r/^https?:\/\//, "")
    "//www.google.com/s2/favicons?domain=#{domain}"
  end

  def script_embed_code(conn, %CodeFund.Schema.Property{} = property) do
    url = "https://#{conn.host}/scripts/#{property.id}/embed.js"
    '''
    <script src="#{url}"></script>
    <div id="codefund_ad"></div>
    '''
  end
end
