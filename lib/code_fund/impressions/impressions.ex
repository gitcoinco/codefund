defmodule CodeFund.Impressions do
  @moduledoc """
  The Impressions context.
  """

  use CodeFundWeb, :query

  alias CodeFund.Schema.Impression
  import Framework.Ecto.Date

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of impressions using filtrex filters.
  """
  def paginate_impressions(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:impressions), params["impression"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_impressions(filter, params) do
      {:ok,
       %{
         impressions: page.entries,
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

  defp do_paginate_impressions(filter, params) do
    Impression
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of impressions.

  ## Examples

      iex> list_impressions()
      [%Impression{}, ...]

  """
  def list_impressions do
    Repo.all(Impression)
  end

  @doc """
  Gets a single impression.

  Raises `Ecto.NoResultsError` if the Impression does not exist.

  ## Examples

      iex> get_impression!(123)
      %Impression{}

      iex> get_impression!(456)
      ** (Ecto.NoResultsError)

  """
  def get_impression!(id), do: Repo.get!(Impression, id) |> Repo.preload([:property, :campaign])

  @doc """
  Creates a impression.

  ## Examples

      iex> create_impression(%{field: value})
      {:ok, %Impression{}}

      iex> create_impression(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_impression(attrs \\ %{}) do
    Appsignal.increment_counter("impressions.create", 1)

    %Impression{}
    |> Impression.changeset(attrs)
    |> Repo.insert()
  end

  def create_from_sponsorship(params, nil), do: params |> create_impression()

  @doc """
  Updates a impression.

  ## Examples

      iex> update_impression(impression, %{field: new_value})
      {:ok, %Impression{}}

      iex> update_impression(impression, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_impression(%Impression{} = impression, attrs) do
    impression
    |> Impression.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Impression.

  ## Examples

      iex> delete_impression(impression)
      {:ok, %Impression{}}

      iex> delete_impression(impression)
      {:error, %Ecto.Changeset{}}

  """
  def delete_impression(%Impression{} = impression) do
    Repo.delete(impression)
  end

  def by_user_in_date_range(user_id, start_date, end_date) do
    from(
      i in CodeFund.Schema.Impression,
      join: p in CodeFund.Schema.Property,
      on: i.property_id == p.id,
      where:
        p.user_id == ^user_id and i.inserted_at >= ^parse(start_date) and
          i.inserted_at <= ^parse(end_date) and is_nil(i.distribution_id)
    )
  end

  def distribution_amount(user_id, start_date, end_date) do
    by_user_in_date_range(user_id, start_date, end_date)
    |> select([i], %{
      "distribution_amount" => sum(i.distribution_amount),
      "impression_count" => count(i.id)
    })
    |> CodeFund.Repo.one()
  end

  defp filter_config(:impressions) do
    defconfig do
      text(:ip)
    end
  end
end
