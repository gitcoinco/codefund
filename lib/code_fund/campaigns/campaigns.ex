defmodule CodeFund.Campaigns do
  @moduledoc """
  The Campaigns context.
  """

  use CodeFundWeb, :query

  alias Decimal, as: D
  alias CodeFund.Schema.{Campaign, User}

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Returns the list of campaigns.

  ## Examples

      iex> list_campaigns()
      [%Campaign{}, ...]

  """
  def paginate_campaigns(%User{} = user, params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:campaigns), params["campaign"] || %{}),
        %Scrivener.Page{} = page <- do_paginate_campaigns(user, filter, params) do
      # campaigns = Enum.map(page.entries, fn(c) ->  end)
      {:ok,
        %{
          campaigns: page.entries,
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

  defp do_paginate_campaigns(%User{} = user, _filter, params) do
    Campaign
    |> where([p], p.user_id == ^user.id)
    |> preload([:user, :budgeted_campaign])
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Gets a single campaign.

  Raises `Ecto.NoResultsError` if the Campaign does not exist.

  ## Examples

      iex> get_campaign!(123)
      %Campaign{}

      iex> get_campaign!(456)
      ** (Ecto.NoResultsError)

  """
  def get_campaign!(id) do
    Campaign
    |> Repo.get!(id)
    |> Repo.preload([:user, :budgeted_campaign])
  end

  def get_campaign_by_name!(name) do
    Campaign
    |> Repo.get_by!(name: name)
    |> Repo.preload([:user, :budgeted_campaign])
  end

  @doc """
  Creates a campaign.

  ## Examples

      iex> create_campaign(%{field: value})
      {:ok, %Campaign{}}

      iex> create_campaign(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_campaign(attrs \\ %{}) do
    %Campaign{}
    |> Campaign.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a campaign.

  ## Examples

      iex> update_campaign(campaign, %{field: new_value})
      {:ok, %Campaign{}}

      iex> update_campaign(campaign, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_campaign(%Campaign{} = campaign, attrs) do
    campaign
    |> Campaign.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Campaign.

  ## Examples

      iex> delete_campaign(campaign)
      {:ok, %Campaign{}}

      iex> delete_campaign(campaign)
      {:error, %Ecto.Changeset{}}

  """
  def delete_campaign(%Campaign{} = campaign) do
    Repo.delete(campaign)
  end


  @doc """
  Returns an `%Ecto.Changeset{}` for tracking campaign changes.

  ## Examples

      iex> change_campaign(campaign)
      %Ecto.Changeset{source: %Campaign{}}

  """
  def change_campaign(%Campaign{} = campaign) do
    Campaign.changeset(campaign, %{})
  end

  def has_remaining_budget?(%Campaign{} = campaign) do
    budgeted_campaign = campaign.budgeted_campaign
    Enum.all?([
      (D.cmp(budgeted_campaign.day_remain, D.new(0)) == :gt),
      (D.cmp(budgeted_campaign.month_remain, D.new(0)) == :gt),
      (D.cmp(budgeted_campaign.total_remain, D.new(0)) == :gt)
    ])
  end

  defp filter_config(:campaigns) do
    defconfig do
      text :name
      text :redirect_url
      number :status
      text :description
      number :bid_amount_cents
      number :daily_budget_cents
      number :monthly_budget_cents
      number :total_budget_cents
    end
  end
end
