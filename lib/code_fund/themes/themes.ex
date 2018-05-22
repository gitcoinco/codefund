defmodule CodeFund.Themes do
  import CodeFund.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config
  import Ecto.Query, warn: false
  alias CodeFund.Repo
  alias CodeFund.Schema.{Theme, Template}

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Returns the list of themes.

  ## Examples

      iex> list_themes()
      [%Theme{}, ...]

  """
  def list_themes do
    Theme
    |> Repo.all()
    |> Repo.preload([:template])
  end

  @spec list_themes_for_template(%Template{}) :: [Ecto.Schema.t()]
  def list_themes_for_template(%Template{} = template) do
    Repo.all(
      from(
        t in Theme,
        where: t.template_id == ^template.id,
        order_by: fragment("lower(?)", t.name)
      )
    )
  end

  @doc """
  Paginate the list of themes using filtrex filters.
  """
  def paginate_themes(_user, params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:themes), params["theme"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_themes(filter, params) do
      {:ok,
       %{
         themes: page.entries,
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

  defp do_paginate_themes(filter, params) do
    Theme
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> preload([:template])
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Gets a single theme.

  Raises `Ecto.NoResultsError` if the Theme does not exist.

  ## Examples

      iex> get_theme!(123)
      %Theme{}

      iex> get_theme!(456)
      ** (Ecto.NoResultsError)

  """
  def get_theme!(id), do: Repo.get!(Theme, id)

  def get_template_or_theme_by_slugs(theme_slug, template_slug) do
    case get_theme_by_slug_and_template(theme_slug, template_slug) do
      %Theme{} = theme -> theme
      nil -> CodeFund.Templates.get_template_by_slug(template_slug)
    end
  end

  defp get_theme_by_slug_and_template(theme_slug, template_slug) do
    from(
      theme in Theme,
      join: template in assoc(theme, :template),
      where: theme.slug == ^theme_slug,
      where: template.slug == ^template_slug,
      preload: [:template]
    )
    |> Repo.one()
  end

  @doc """
  Creates a theme.

  ## Examples

      iex> create_theme(%{field: value})
      {:ok, %Theme{}}

      iex> create_theme(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_theme(attrs \\ %{}) do
    %Theme{}
    |> Theme.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a theme.

  ## Examples

      iex> update_theme(theme, %{field: new_value})
      {:ok, %Theme{}}

      iex> update_theme(theme, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_theme(%Theme{} = theme, attrs) do
    theme
    |> Theme.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Theme.

  ## Examples

      iex> delete_theme(theme)
      {:ok, %Theme{}}

      iex> delete_theme(theme)
      {:error, %Ecto.Changeset{}}

  """
  def delete_theme(%Theme{} = theme) do
    Repo.delete(theme)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking theme changes.

  ## Examples

      iex> change_theme(theme)
      %Ecto.Changeset{source: %Theme{}}

  """
  def change_theme(%Theme{} = theme) do
    Theme.changeset(theme, %{})
  end

  defp filter_config(:themes) do
    defconfig do
      text(:name)
      text(:slug)
    end
  end
end
