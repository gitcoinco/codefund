defmodule CodeFund.Sponsorships do
  @moduledoc """
  The Sponsorships context.
  """

  use CodeFundWeb, :query

  alias CodeFund.Schema.{Sponsorship, Property, Campaign, User}
  alias CodeFund.Campaigns

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of sponsorships using filtrex filters.
  """
  def paginate_sponsorships(%User{} = user, params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:sponsorships), params["sponsorship"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_sponsorships(user, filter, params) do
      {:ok,
       %{
         sponsorships: page.entries,
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

  defp do_paginate_sponsorships(%User{} = user, _filter, params) do
    case Enum.member?(user.roles, "admin") do
      true ->
        Sponsorship
        |> order_by(^sort(params))
        |> preload([:campaign, :property, :creative, :user])
        |> paginate(Repo, params, @pagination)

      false ->
        Sponsorship
        |> where([sponsorship], sponsorship.user_id == ^user.id)
        |> order_by(^sort(params))
        |> preload([:campaign, :property, :creative, :user])
        |> paginate(Repo, params, @pagination)
    end
  end

  @doc """
  Returns the list of sponsorships.

  ## Examples

      iex> list_sponsorships()
      [%Sponsorship{}, ...]

  """
  def list_sponsorships do
    Sponsorship
    |> Repo.all()
    |> Repo.preload([:property, :campaign, :creative, :user])
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
  def get_sponsorship!(id) do
    Sponsorship
    |> Repo.get!(id)
    |> Repo.preload([:property, :campaign, :creative, :user])
  end

  def get_and_update_sponsorship_for_property(
        %Property{} = property,
        campaign_order \\ :bid_amount
      ) do
    case campaign_order do
      :bid_amount ->
        property
        |> Campaigns.get_active_campaign_for_property_with_biggest_bid_amount()
        |> get_and_update_sponsorship_for_property_by_campaign(property)

      :random ->
        property
        |> Campaigns.get_random_active_campaign_for_property()
        |> get_and_update_sponsorship_for_property_by_campaign(property)
    end
  end

  defp get_and_update_sponsorship_for_property_by_campaign(
         %Campaign{} = campaign,
         %Property{} = property
       ) do
    %Sponsorship{} = sponsorship = get_sponsorships_by_campaign_and_property(campaign, property)

    {:ok, %Property{}} =
      Property.changeset(property, %{sponsorship_id: sponsorship.id}) |> Repo.update()

    sponsorship
  end

  defp get_and_update_sponsorship_for_property_by_campaign(nil, %Property{} = property) do
    Property.changeset(property, %{sponsorship_id: nil}) |> Repo.update()
    nil
  end

  def get_sponsorships_by_campaign_and_property(
        %Campaign{} = campaign,
        %Property{} = property,
        limit \\ 1
      ) do
    from(
      s in Sponsorship,
      where: s.property_id == ^property.id,
      where: s.campaign_id == ^campaign.id,
      limit: ^limit
    )
    |> Repo.one()
    |> Repo.preload([:campaign, :property, :creative, :user])
  end

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
    from(
      p in Property,
      join: s in Sponsorship,
      on: p.sponsorship_id == s.id
    )
    |> update(set: [sponsorship_id: nil])
    |> Repo.update_all([])

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

  defp filter_config(:sponsorships) do
    defconfig do
      text(:redirect_url)
      number(:bid_amount)
    end
  end
end
