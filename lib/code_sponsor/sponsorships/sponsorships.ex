defmodule CodeSponsor.Sponsorships do
  @moduledoc """
  The Sponsorships context.
  """

  import Ecto.Query, warn: false
  alias CodeSponsor.Repo

  alias CodeSponsor.Sponsorships.Sponsorship

  @doc """
  Returns the list of sponsorships.

  ## Examples

      iex> list_sponsorships()
      [%Sponsorship{}, ...]

  """
  def list_sponsorships do
    Repo.all(Sponsorship)
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
  def get_sponsorship!(id), do: Repo.get!(Sponsorship, id)

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
end
