defmodule CodeFundWeb.PageView do
  use CodeFundWeb, :view

  @spec title(any()) :: <<_::64, _::_*8>>
  def title(:index), do: "CodeFund"
  def title(:advertiser), do: "Advertise with Us | CodeFund"
  def title(:publisher), do: "Become a Publisher | CodeFund"
  def title(:advertisers), do: "Advertise with Us | CodeFund"
  def title(:publishers), do: "Become a Publisher | CodeFund"
  def title(:blog), do: "Blog | CodeFund"
  def title(:help), do: "Help | CodeFund"
  def title(:ethical_advertising), do: "Ethical Advertising | CodeFund"
  def title(:team), do: "Team | CodeFund"
  def title(:about), do: "About | CodeFund"
  def title(:media_kit), do: "Media Kit | CodeFund"
  def title(_), do: "CodeFund"
  def body_class(_), do: "app mt-5"

  @spec headline_link() :: {:safe, <<_::64, _::_*8>>}
  def headline_link do
    headline_title = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:home_headline_title]
    headline_link = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:home_headline_link]

    {:safe,
     "<a class=\"text-secondary\" href=\"#{headline_link}\" target=\"_blank\">#{headline_title}</a>"}
  end
end
