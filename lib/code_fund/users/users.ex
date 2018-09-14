defmodule CodeFund.Users do
  @roles [Admin: "admin", Developer: "developer", Sponsor: "sponsor"]
  import Ecto.Query
  alias CodeFund.Repo
  alias CodeFund.Schema.User

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

  def get_by_role(role) do
    from(u in User, where: ^role in u.roles, order_by: [asc: u.first_name]) |> Repo.all()
  end

  def get_by_api_key(api_key) do
    from(u in User, where: ^api_key == u.api_key) |> Repo.one()
  end

  def roles, do: @roles

  def update_user(%User{} = user, attrs) do
    changeset =
      user
      |> User.changeset(attrs)

    CodeFund.Properties.update_excluded_advertisers(changeset)

    changeset
    |> Repo.update()
  end

  def has_role?(existing_roles, target_roles) do
    Enum.any?(target_roles, fn role ->
      Enum.member?(existing_roles, role)
    end)
  end

  @spec distinct_companies() :: [String.t()]
  def distinct_companies() do
    from(
      u in User,
      select: u.company,
      distinct: u.company,
      where: not is_nil(u.company),
      order_by: [asc: u.company]
    )
    |> Repo.all()
  end
end
