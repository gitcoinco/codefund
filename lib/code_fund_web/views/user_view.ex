defmodule CodeFundWeb.UserView do
  use CodeFundWeb, :view

  def title(:index), do: "CodeFund | Users"

  def body_class(_), do: "app flex-row align-items-center"
end
