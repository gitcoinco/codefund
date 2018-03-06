defmodule CodeSponsorWeb.PageView do
  use CodeSponsorWeb, :view

  def title(:index), do: "CHANGEME: INDEX"
  def title(_),      do: "CHANGEME"
  def body_class(_), do: "app mt-5"
end
