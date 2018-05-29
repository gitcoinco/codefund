defmodule CodeFund.Creatives do
  @moduledoc """
  The Creatives context.
  """

  import CodeFund.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config
  import Ecto.Query, warn: false
  alias CodeFund.Repo
  alias CodeFund.Schema.{Creative, User}

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of creatives using filtrex filters.
  """
  def paginate_creatives(%User{} = user, params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:creatives), params["creative"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_creatives(user, filter, params) do
      {:ok,
       %{
         creatives: page.entries,
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

  defp do_paginate_creatives(%User{} = user, _filter, params) do
    case Enum.member?(user.roles, "admin") do
      true ->
        Creative
        |> preload(:user)
        |> order_by(^sort(params))
        |> paginate(Repo, params, @pagination)

      false ->
        Creative
        |> where([p], p.user_id == ^user.id)
        |> order_by(^sort(params))
        |> paginate(Repo, params, @pagination)
    end
  end

  def by_user(%User{id: id}) do
    from(o in Creative, where: o.user_id == ^id)
    |> CodeFund.Repo.all()
  end

  @doc """
  Gets a single creative.

  Raises `Ecto.NoResultsError` if the Creative does not exist.

  ## Examples

      iex> get_creative!(123)
      %Creative{}

      iex> get_creative!(456)
      ** (Ecto.NoResultsError)

  """
  def get_creative!(id), do: Repo.get!(Creative, id) |> Repo.preload(:user)

  @doc """
  Creates a creative.

  ## Examples

      iex> create_creative(%{field: value})
      {:ok, %Creative{}}

      iex> create_creative(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_creative(attrs \\ %{}) do
    %Creative{}
    |> Creative.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a creative.

  ## Examples

      iex> update_creative(creative, %{field: new_value})
      {:ok, %Creative{}}

      iex> update_creative(creative, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_creative(%Creative{} = creative, attrs) do
    creative
    |> Creative.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Creative.

  ## Examples

      iex> delete_creative(creative)
      {:ok, %Creative{}}

      iex> delete_creative(creative)
      {:error, %Ecto.Changeset{}}

  """
  def delete_creative(%Creative{} = creative) do
    Repo.delete(creative)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking creative changes.

  ## Examples

      iex> change_creative(creative)
      %Ecto.Changeset{source: %Creative{}}

  """
  def change_creative(%Creative{} = creative) do
    Creative.changeset(creative, %{})
  end

  @doc """
  Returns the list of creatives.

  ## Examples

      iex> list_creatives()
      [%Creative{}, ...]

  """
  def list_creatives do
    Repo.all(Creative)
  end

  defp filter_config(:creatives) do
    defconfig do
      text(:name)
    end
  end
end
