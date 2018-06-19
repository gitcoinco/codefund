defmodule CodeFund.Distributions do
  @moduledoc """
  The Distributions context.
  """

  use CodeFundWeb, :query
  alias CodeFund.Schema.Distribution

  @pagination [page_size: 15]
  @pagination_distance 5

  def get_distribution!(id) do
    Distribution
    |> Repo.get!(id)
    |> Repo.preload(impressions: [property: :user])
  end

  @doc """
  Paginate the list of distributions using filtrex filters.
  """
  def paginate_distributions(_user, params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:distributions), params["distribution"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_distributions(filter, params) do
      {:ok,
       %{
         distributions: page.entries,
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

  defp do_paginate_distributions(_filter, params) do
    Distribution
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Creates a distribution.

  ## Examples

      iex> create_distribution(%{field: value})
      {:ok, %Distribution{}}

      iex> create_distribution(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_distribution(attrs \\ %{}) do
    %Distribution{}
    |> Distribution.changeset(attrs)
    |> Repo.insert()
  end

  defp filter_config(:distributions) do
    defconfig do
      text(:amount)
      date(:range_start)
      date(:range_end)
    end
  end
end
