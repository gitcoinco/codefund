defmodule CodeFund.Audiences do
  @moduledoc """
  The Audiences context.
  """

  use CodeFundWeb, :query
  alias CodeFund.Schema.Audience

  @pagination [page_size: 15]
  @pagination_distance 5

  def get_audience!(id) do
    Audience
    |> Repo.get!(id)
    |> Repo.preload(:campaigns)
  end

  @doc """
  Returns the list of audiences.

  ## Examples

      iex> list_audiences()
      [%Audience{}, ...]

  """
  def list_audiences do
    Repo.all(Audience)
    |> Repo.preload(:campaigns)
  end

  @doc """
  Paginate the list of audiences using filtrex filters.
  """
  def paginate_audiences(_user, params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:audiences), params["audience"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_audiences(filter, params) do
      {:ok,
       %{
         audiences: page.entries,
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

  defp do_paginate_audiences(_filter, params) do
    Audience
    |> preload(:campaigns)
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Creates a audience.

  ## Examples

      iex> create_audience(%{field: value})
      {:ok, %Audience{}}

      iex> create_audience(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_audience(attrs \\ %{}) do
    %Audience{}
    |> Audience.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a audience.

  ## Examples

      iex> update_audience(audience, %{field: new_value})
      {:ok, %Audience{}}

      iex> update_audience(audience, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_audience(%Audience{} = audience, attrs) do
    audience
    |> Audience.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Audience.

  ## Examples

      iex> delete_audience(audience)
      {:ok, %Audience{}}

      iex> delete_audience(audience)
      {:error, %Ecto.Changeset{}}

  """
  def delete_audience(%Audience{} = audience) do
    Repo.delete(audience)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking audience changes.

  ## Examples

      iex> change_audience(audience)
      %Ecto.Changeset{source: %Audience{}}

  """
  def change_audience(%Audience{} = audience) do
    Audience.changeset(audience, %{})
  end

  defp filter_config(:audiences) do
    defconfig do
      text(:name)
    end
  end
end
