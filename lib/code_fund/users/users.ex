defmodule CodeFund.Users do
  @roles [Admin: "admin", Developer: "developer", Sponsor: "sponsor"]
  alias CodeFund.Repo

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    CodeFund.Schema.User
    |> Repo.get!(id)
  end

  def roles, do: @roles

  def has_role?(existing_roles, target_roles) do
    Enum.any?(target_roles, fn role ->
      Enum.member?(existing_roles, role)
    end)
  end
end
