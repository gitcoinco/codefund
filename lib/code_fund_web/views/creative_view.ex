defmodule CodeFundWeb.CreativeView do
  use CodeFundWeb, :view

  import CodeFundWeb.TableView

  def title(:index), do: "CodeFund | Creatives"
  def title(:new),   do: "CodeFund | Add Creative"
  def title(:edit),  do: "CodeFund | Edit Creative"
  def title(:show),  do: "CodeFund | View Creative"
end
