defmodule CodeFund.Assets do
  @moduledoc """
  The Assets context.
  """

  import CodeFund.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config
  import Ecto.Query, warn: false
  alias CodeFund.Repo
  alias CodeFund.Schema.{Asset, User}

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of assets using filtrex filters.
  """
  def paginate_assets(%User{} = user, params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:assets), params["asset"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_assets(user, filter, params) do
      {:ok,
       %{
         assets: page.entries,
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

  defp do_paginate_assets(%User{} = user, _filter, params) do
    case Enum.member?(user.roles, "admin") do
      true ->
        Asset
        |> preload(:user)
        |> order_by(^sort(params))
        |> paginate(Repo, params, @pagination)

      false ->
        Asset
        |> where([p], p.user_id == ^user.id)
        |> order_by(^sort(params))
        |> paginate(Repo, params, @pagination)
    end
  end

  def by_user_id(user_id) do
    from(o in Asset, where: o.user_id == ^user_id, order_by: fragment("lower(?)", o.name))
    |> CodeFund.Repo.all()
  end

  @doc """
  Gets a single asset.

  Raises `Ecto.NoResultsError` if the Asset does not exist.

  ## Examples

      iex> get_asset!(123)
      %Asset{}

      iex> get_asset!(456)
      ** (Ecto.NoResultsError)

  """
  def get_asset!(id), do: Repo.get!(Asset, id) |> Repo.preload(:user)

  @doc """
  Creates a asset.

  ## Examples

      iex> create_asset(%{field: value})
      {:ok, %Asset{}}

      iex> create_asset(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_asset(attrs \\ %{}) do
    %Asset{}
    |> Asset.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a asset.

  ## Examples

      iex> update_asset(asset, %{field: new_value})
      {:ok, %Asset{}}

      iex> update_asset(asset, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_asset(%Asset{} = asset, attrs) do
    asset
    |> Asset.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Asset.

  ## Examples

      iex> delete_asset(asset)
      {:ok, %Asset{}}

      iex> delete_asset(asset)
      {:error, %Ecto.Changeset{}}

  """
  def delete_asset(%Asset{} = asset) do
    Repo.delete(asset)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking asset changes.

  ## Examples

      iex> change_asset(asset)
      %Ecto.Changeset{source: %Asset{}}

  """
  def change_asset(%Asset{} = asset) do
    Asset.changeset(asset, %{})
  end

  @doc """
  Returns the list of assets.

  ## Examples

      iex> list_assets()
      [%Asset{}, ...]

  """
  def list_assets do
    from(a in Asset, order_by: fragment("lower(?)", a.name))
    |> Repo.all()
  end

  defp filter_config(:assets) do
    defconfig do
      text(:name)
    end
  end
end
