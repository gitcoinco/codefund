defmodule CodeFundWeb.PropertyView do
  use CodeFundWeb, :view

  import CodeFundWeb.TableView

  def body_class(_), do: "app flex-row align-items-center"

  def favicon_image_url(url) do
    domain = String.replace(url, ~r/^https?:\/\//, "")
    "//www.google.com/s2/favicons?domain=#{domain}"
  end

  def script_embed_url(%Plug.Conn{host: host}, %CodeFund.Schema.Property{id: id}) do
    "https://#{host}/scripts/#{id}/embed.js"
  end

  def script_embed_code(conn, %CodeFund.Schema.Property{} = property) do
    '''
    <script src="#{script_embed_url(conn, property)}"></script>
    <div id="codefund_ad"></div>
    '''
  end
end
