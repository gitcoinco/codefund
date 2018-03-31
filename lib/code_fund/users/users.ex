defmodule CodeFund.Users do
  @roles [Admin: "admin", Developer: "developer", Sponsor: "sponsor"]

  def roles, do: @roles
end
