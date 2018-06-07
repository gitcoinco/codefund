defmodule CodeFund.InsertionOrders do
  @moduledoc """
  The InsertionOrders context.
  """

  import CodeFund.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config
  import Ecto.Query, warn: false
  alias CodeFund.Repo
  alias CodeFund.Schema.InsertionOrder

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of insertion_orders using filtrex filters.
  """
  def paginate_insertion_orders(_user, params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(
             filter_config(:insertion_orders),
             params["insertion_order"] || %{}
           ),
         %Scrivener.Page{} = page <- do_paginate_insertion_orders(filter, params) do
      {:ok,
       %{
         insertion_orders: page.entries,
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

  defp do_paginate_insertion_orders(_filter, params) do
    InsertionOrder
    |> preload([:user, :audience])
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Gets a single insertion_order.

  Raises `Ecto.NoResultsError` if the InsertionOrder does not exist.

  ## Examples

      iex> get_insertion_order!(123)
      %InsertionOrder{}

      iex> get_insertion_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_insertion_order!(id),
    do: Repo.get!(InsertionOrder, id) |> Repo.preload([:audience, :user])

  @doc """
  Creates a insertion_order.

  ## Examples

      iex> create_insertion_order(%{field: value})
      {:ok, %InsertionOrder{}}

      iex> create_insertion_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_insertion_order(attrs \\ %{}) do
    %InsertionOrder{}
    |> InsertionOrder.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a insertion_order.

  ## Examples

      iex> update_insertion_order(insertion_order, %{field: new_value})
      {:ok, %InsertionOrder{}}

      iex> update_insertion_order(insertion_order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_insertion_order(%InsertionOrder{} = insertion_order, attrs) do
    insertion_order
    |> InsertionOrder.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a InsertionOrder.

  ## Examples

      iex> delete_insertion_order(insertion_order)
      {:ok, %InsertionOrder{}}

      iex> delete_insertion_order(insertion_order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_insertion_order(%InsertionOrder{} = insertion_order) do
    Repo.delete(insertion_order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking insertion_order changes.

  ## Examples

      iex> change_insertion_order(insertion_order)
      %Ecto.Changeset{source: %InsertionOrder{}}

  """
  def change_insertion_order(%InsertionOrder{} = insertion_order) do
    InsertionOrder.changeset(insertion_order, %{})
  end

  @doc """
  Returns the list of insertion_orders.

  ## Examples

      iex> list_insertion_orders()
      [%InsertionOrder{}, ...]

  """
  def list_insertion_orders do
    Repo.all(InsertionOrder)
  end

  defp filter_config(:insertion_orders) do
    defconfig do
      text(:user_id)
      text(:audience_id)
      text(:impression_count)
      text(:billing_cycle)
    end
  end
end
