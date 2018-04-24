defmodule CodeFund.Sponsorships do
  @moduledoc """
  The Sponsorships context.
  """

  use CodeFundWeb, :query

  alias CodeFund.Schema.{Sponsorship, Property, User}

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of sponsorships using filtrex filters.
  """
  def paginate_sponsorships(%User{} = user, params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:sponsorships), params["sponsorship"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_sponsorships(user, filter, params) do
      {:ok,
       %{
         sponsorships: page.entries,
         page_number: page.page_number,
         page_size: page.page_size,
         total_pages: page.total_pages,
         total_entries: page.total_entries,
         distance: @pagination_distance,
         sort_field: sort_field,
         sort_direction: sort_direction
       }}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_sponsorships(%User{} = user, _filter, params) do
    case Enum.member?(user.roles, "admin") do
      true ->
        Sponsorship
        |> order_by(^sort(params))
        |> preload([:campaign, :property, :creative, :user])
        |> paginate(Repo, params, @pagination)

      false ->
        Sponsorship
        |> where([sponsorship], sponsorship.user_id == ^user.id)
        |> order_by(^sort(params))
        |> preload([:campaign, :property, :creative, :user])
        |> paginate(Repo, params, @pagination)
    end
  end

  @doc """
  Returns the list of sponsorships.

  ## Examples

      iex> list_sponsorships()
      [%Sponsorship{}, ...]

  """
  def list_sponsorships do
    Sponsorship
    |> Repo.all()
    |> Repo.preload([:property, :campaign, :creative, :user])
  end

  @doc """
  Gets a single sponsorship.

  Raises `Ecto.NoResultsError` if the Sponsorship does not exist.

  ## Examples

      iex> get_sponsorship!(123)
      %Sponsorship{}

      iex> get_sponsorship!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sponsorship!(id) do
    Sponsorship
    |> Repo.get!(id)
    |> Repo.preload([:property, :campaign, :creative, :user])
  end

  @spec get_sponsorship_for_property(%Property{}, integer) :: %Sponsorship{}
  def get_sponsorship_for_property(
        %Property{} = property,
        limit \\ 1
      ) do
    base_query(property)
    |> where([s], s.bid_amount == ^highest_bid_amount_by_property(property))
    |> limit(^limit)
    |> order_by(fragment("RANDOM()"))
    |> Repo.one()
    |> Repo.preload([:campaign, :property, :creative, :user])
  end

  @doc """
  Creates a sponsorship.

  ## Examples

      iex> create_sponsorship(%{field: value})
      {:ok, %Sponsorship{}}

      iex> create_sponsorship(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sponsorship(attrs \\ %{}) do
    %Sponsorship{}
    |> Sponsorship.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sponsorship.

  ## Examples

      iex> update_sponsorship(sponsorship, %{field: new_value})
      {:ok, %Sponsorship{}}

      iex> update_sponsorship(sponsorship, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sponsorship(%Sponsorship{} = sponsorship, attrs) do
    sponsorship
    |> Sponsorship.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Sponsorship.

  ## Examples

      iex> delete_sponsorship(sponsorship)
      {:ok, %Sponsorship{}}

      iex> delete_sponsorship(sponsorship)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sponsorship(%Sponsorship{} = sponsorship) do
    from(
      p in Property,
      join: s in Sponsorship,
      on: p.sponsorship_id == s.id
    )
    |> update(set: [sponsorship_id: nil])
    |> Repo.update_all([])

    Repo.delete(sponsorship)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sponsorship changes.

  ## Examples

      iex> change_sponsorship(sponsorship)
      %Ecto.Changeset{source: %Sponsorship{}}

  """
  def change_sponsorship(%Sponsorship{} = sponsorship) do
    Sponsorship.changeset(sponsorship, %{})
  end

  defp highest_bid_amount_by_property(property) do
    base_query(property)
    |> select([s], s.bid_amount)
    |> limit(1)
    |> order_by([s], desc: s.bid_amount)
    |> Repo.one() || 0.00
  end

  defp base_query(property) do
    from(
      s in Sponsorship,
      join: c in assoc(s, :campaign),
      join: b in assoc(c, :budgeted_campaign),
      where: c.status == 2,
      where: s.property_id == ^property.id,
      where: b.day_remain > 0,
      where: b.month_remain > 0,
      where: b.total_remain > 0,
      where: s.property_id == ^property.id
    )
  end

  defp filter_config(:sponsorships) do
    defconfig do
      text(:redirect_url)
      number(:bid_amount)
    end
  end
end
