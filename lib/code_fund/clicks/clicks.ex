defmodule CodeFund.Clicks do
  @moduledoc """
  The Clicks context.
  """

  use CodeFundWeb, :query
  alias CodeFund.Schema.Click
  import Framework.Date

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of clicks using filtrex filters.
  """
  def paginate_clicks(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:clicks), params["click"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_clicks(filter, params) do
      {:ok,
       %{
         clicks: page.entries,
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

  defp do_paginate_clicks(_filter, params) do
    Click
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Returns the list of clicks.

  ## Examples

      iex> list_clicks()
      [%Click{}, ...]

  """
  def list_clicks do
    Repo.all(Click)
  end

  def by_user_in_date_range(user_id, start_date, end_date) do
    from(
      c in CodeFund.Schema.Click,
      join: p in CodeFund.Schema.Property,
      on: c.property_id == p.id,
      where:
        p.user_id == ^user_id and c.inserted_at >= ^parse(start_date) and
          c.inserted_at <= ^parse(end_date) and c.status == 1 and is_nil(c.distribution_id)
    )
  end

  def distribution_amount(user_id, start_date, end_date) do
    by_user_in_date_range(user_id, start_date, end_date)
    |> select([c], %{
      "distribution_amount" => sum(c.distribution_amount),
      "click_count" => count(c.id)
    })
    |> CodeFund.Repo.one()
  end

  @doc """
  Gets a single click.

  Raises `Ecto.NoResultsError` if the Click does not exist.

  ## Examples

      iex> get_click!(123)
      %Click{}

      iex> get_click!(456)
      ** (Ecto.NoResultsError)

  """
  def get_click!(id), do: Repo.get!(Click, id)

  @doc """
  Creates a click.

  ## Examples

      iex> create_click(%{field: value})
      {:ok, %Click{}}

      iex> create_click(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_click(attrs \\ %{}) do
    %Click{}
    |> Click.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a click.

  ## Examples

      iex> update_click(click, %{field: new_value})
      {:ok, %Click{}}

      iex> update_click(click, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_click(%Click{} = click, attrs) do
    click
    |> Click.changeset(attrs)
    |> Repo.update()
  end

  def set_status(%Click{} = click, status, attrs \\ %{}) do
    status_int = Click.statuses()[status]

    attrs =
      Map.merge(attrs, %{status: status_int, is_bot: false, is_duplicate: false, is_fraud: false})

    attrs =
      case status do
        :bot -> Map.merge(attrs, %{is_bot: true})
        :duplicate -> Map.merge(attrs, %{is_duplicate: true})
        :fraud -> Map.merge(attrs, %{is_fraud: true})
        _ -> attrs
      end

    click
    |> Click.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Determine if a click is a duplicate

  ## Examples

      iex> is_duplicate(click, %{field: new_value})
      {:ok, %Click{}}

      iex> update_click(click, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def is_duplicate?(impression_id, ip_address) do
    query =
      from(
        c in Click,
        select: count(c.id),
        where: [
          impression_id: ^impression_id,
          ip: ^ip_address,
          status: ^Click.statuses()[:redirected]
        ],
        where: c.inserted_at >= ^Timex.shift(Timex.now(), days: -7)
      )

    matches = query |> Repo.one()
    matches > 0
  end

  @doc """
  Deletes a Click.

  ## Examples

      iex> delete_click(click)
      {:ok, %Click{}}

      iex> delete_click(click)
      {:error, %Ecto.Changeset{}}

  """
  def delete_click(%Click{} = click) do
    Repo.delete(click)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking click changes.

  ## Examples

      iex> change_click(click)
      %Ecto.Changeset{source: %Click{}}

  """
  def change_click(%Click{} = click) do
    Click.changeset(click, %{})
  end

  defp filter_config(:clicks) do
    defconfig do
      text(:ip)
    end
  end
end
