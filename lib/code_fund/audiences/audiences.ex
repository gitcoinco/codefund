defmodule CodeFund.Audiences do
  @moduledoc """
  The Audiences context.
  """

  use CodeFundWeb, :query
  alias CodeFund.Schema.{Audience, User}

  @pagination [page_size: 15]
  @pagination_distance 5

  def get_audience!(id) do
    Audience
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end

  @doc """
  Paginate the list of audiences using filtrex filters.
  """
  def paginate_audiences(user, params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:audiences), params["audience"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_audiences(user, filter, params) do
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

  defp do_paginate_audiences(user, _filter, params) do
    get_by_user(user, params)
    |> paginate(Repo, params, @pagination)
  end

  def get_by_user(%User{} = user, params \\ %{}) do
    case Enum.member?(user.roles, "admin") do
      true ->
        Audience
        |> preload(:user)
        |> order_by(^sort(params))

      false ->
        Audience
        |> where([p], p.user_id == ^user.id)
        |> preload(:user)
        |> order_by(^sort(params))
    end
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
      text(:amount)
      date(:click_range_start)
      text(:click_range_end)
    end
  end
end
