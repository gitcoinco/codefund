defmodule CodeFund.Users do
  @roles [Admin: "admin", Developer: "developer", Sponsor: "sponsor"]

  def roles, do: @roles

  def has_role?(existing_roles, target_roles) do
    Enum.any?(target_roles, fn role ->
      Enum.member?(existing_roles, role)
    end)
  end
end
