defmodule CodeFundWeb.PageView do
  use CodeFundWeb, :view

  def title(:index), do: "CodeFund"
  def title(:advertiser), do: "CodeFund | Advertise with CodeFund"
  def title(:publisher), do: "CodeFund | Become a Publisher"
  def title(_), do: "CodeFund"
  def body_class(_), do: "app mt-5"
end
