defmodule CodeFundWeb.PageView do
  use CodeFundWeb, :view

  def title(:index), do: "CodeFund"
  def title(:advertiser), do: "CodeFund | Advertise with CodeFund"
  def title(:publisher), do: "CodeFund | Become a Publisher"
  def title(_), do: "CodeFund"
  def body_class(_), do: "app mt-5"

  def headline_link do
    headline_title = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:home_headline_title]
    headline_link = Application.get_env(:code_fund, CodeFundWeb.Endpoint)[:home_headline_link]

    {:safe, "<a class=\"text-secondary\" href=\"#{headline_link}\" target=\"_blank\">#{headline_title}</a>"}
  end
end
