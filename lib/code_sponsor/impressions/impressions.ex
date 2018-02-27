defmodule CodeSponsor.Impressions do
  @moduledoc """
  The Impressions context.
  """

  import Ecto.Query, warn: false
  alias CodeSponsor.Repo

  alias CodeSponsor.Impressions.Impression

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
  def get_impression!(id), do: Repo.get!(Impression, id)

  @doc """
  Creates a impression.

  ## Examples

      iex> create_impression(%{field: value})
      {:ok, %Impression{}}

      iex> create_impression(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_impression(attrs \\ %{}) do
    %Impression{}
    |> Impression.changeset(attrs)
    |> Repo.insert()
  end

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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking impression changes.

  ## Examples

      iex> change_impression(impression)
      %Ecto.Changeset{source: %Impression{}}

  """
  def change_impression(%Impression{} = impression) do
    Impression.changeset(impression, %{})
  end
end
