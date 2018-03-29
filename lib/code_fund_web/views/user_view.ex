defmodule CodeFundWeb.UserView do
  use CodeFundWeb, :view

  def title(:index), do: "CodeFund | Users"
  def title(:edit),  do: "CodeFund | Edit User"
  def title(:show),  do: "CodeFund | View User"

  def body_class(_), do: "app flex-row align-items-center"
end
