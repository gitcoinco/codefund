defmodule CodeSponsor.Properties do
  @moduledoc """
  The Properties context.
  """

  use CodeSponsorWeb, :query

  alias CodeSponsor.Schema.Property
  alias CodeSponsor.Schema.User

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of properties using filtrex filters.
  """
  def paginate_properties(%User{} = user, params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:properties), params["property"] || %{}),
        %Scrivener.Page{} = page <- do_paginate_properties(user, filter, params) do
      {:ok,
        %{
          properties: page.entries,
          page_number: page.page_number,
          page_size: page.page_size,
          total_pages: page.total_pages,
          total_entries: page.total_entries,
          distance: @pagination_distance,
          sort_field: sort_field,
          sort_direction: sort_direction
        }
      }
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_properties(%User{} = user, filter, params) do
    Property
    |> where([p], p.user_id == ^user.id)
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of properties.

  ## Examples

      iex> list_properties()
      [%Property{}, ...]

  """
  def list_properties do
    Repo.all(Property)
  end

  @doc """
  Gets a single property.

  Raises `Ecto.NoResultsError` if the Property does not exist.

  ## Examples

      iex> get_property!(123)
      %Property{}

      iex> get_property!(456)
      ** (Ecto.NoResultsError)

  """
  def get_property!(id) do
    try do
      case Ecto.UUID.cast(id) do
        {:ok, _} -> Repo.get!(Property, id)
        :error   -> Repo.get_by!(Property, legacy_id: id)
      end
    rescue
      Ecto.NoResultsError ->
        Repo.get_by!(Property, legacy_id: id)
    end
  end

  @doc """
  Creates a property.

  ## Examples

      iex> create_property(%{field: value})
      {:ok, %Property{}}

      iex> create_property(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_property(attrs \\ %{}) do
    %Property{}
    |> Property.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a property.

  ## Examples

      iex> update_property(property, %{field: new_value})
      {:ok, %Property{}}

      iex> update_property(property, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_property(%Property{} = property, attrs) do
    property
    |> Property.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Property.

  ## Examples

      iex> delete_property(property)
      {:ok, %Property{}}

      iex> delete_property(property)
      {:error, %Ecto.Changeset{}}

  """
  def delete_property(%Property{} = property) do
    Repo.delete(property)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking property changes.

  ## Examples

      iex> change_property(property)
      %Ecto.Changeset{source: %Property{}}

  """
  def change_property(%Property{} = property) do
    Property.changeset(property, %{})
  end

  def change_property(%Property{} = property, %{user: user} = _params) do
    Property.changeset(property, user)
  end

  defp filter_config(:properties) do
    defconfig do
      text :name
      text :url
      text :description
    end
  end
end
