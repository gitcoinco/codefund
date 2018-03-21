defmodule CodeSponsor.Creatives do
  @moduledoc """
  The Creatives context.
  """

  import CodeSponsor.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config
  import Ecto.Query, warn: false
  alias CodeSponsor.Repo
  alias CodeSponsor.Creatives.{Creative, Template, Theme}

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Returns the list of templates.

  ## Examples

      iex> list_templates()
      [%Template{}, ...]

  """
  def list_templates do
    Template
    |> Repo.all
    |> Repo.preload([:themes])
  end

  @doc """
  Paginate the list of templates using filtrex filters.
  """
  def paginate_templates(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:templates), params["template"] || %{}),
        %Scrivener.Page{} = page <- do_paginate_templates(filter, params) do
      {:ok,
        %{
          templates: page.entries,
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

  defp do_paginate_templates(filter, params) do
    Template
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> preload([:themes])
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Gets a single template.

  Raises `Ecto.NoResultsError` if the Template does not exist.

  ## Examples

      iex> get_template!(123)
      %Template{}

      iex> get_template!(456)
      ** (Ecto.NoResultsError)

  """
  def get_template!(id), do: Repo.get!(Template, id)

  def get_template_by_slug(slug) do
    Template
    |> Repo.get_by(slug: slug)
    |> Repo.preload([:themes])
  end

  @doc """
  Creates a template.

  ## Examples

      iex> create_template(%{field: value})
      {:ok, %Template{}}

      iex> create_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_template(attrs \\ %{}) do
    %Template{}
    |> Template.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a template.

  ## Examples

      iex> update_template(template, %{field: new_value})
      {:ok, %Template{}}

      iex> update_template(template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_template(%Template{} = template, attrs) do
    template
    |> Template.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Template.

  ## Examples

      iex> delete_template(template)
      {:ok, %Template{}}

      iex> delete_template(template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_template(%Template{} = template) do
    Repo.delete(template)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking template changes.

  ## Examples

      iex> change_template(template)
      %Ecto.Changeset{source: %Template{}}

  """
  def change_template(%Template{} = template) do
    Template.changeset(template, %{})
  end

  @doc """
  Returns the list of themes.

  ## Examples

      iex> list_themes()
      [%Theme{}, ...]

  """
  def list_themes do
    Theme
    |> Repo.all
    |> Repo.preload([:template])
  end

  @doc """
  Paginate the list of themes using filtrex filters.
  """
  def paginate_themes(params \\ %{}) do
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
        }
      }
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

  def get_theme_by_slug!(slug) do
    Repo.get_by!(Theme, slug: slug) |> Repo.preload([:template])
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

  @doc """
  Returns the list of creatives.

  ## Examples

      iex> list_creatives()
      [%Creative{}, ...]

  """
  def list_creatives do
    Repo.all(Creative)
  end

  @doc """
  Paginate the list of creatives using filtrex filters.
  """
  def paginate_creatives(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:creatives), params["creative"] || %{}),
        %Scrivener.Page{} = page <- do_paginate_creatives(filter, params) do
      {:ok,
        %{
          creatives: page.entries,
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

  defp do_paginate_creatives(filter, params) do
    Creative
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  @doc """
  Gets a single creative.

  Raises `Ecto.NoResultsError` if the Creative does not exist.

  ## Examples

      iex> get_creative!(123)
      %Creative{}

      iex> get_creative!(456)
      ** (Ecto.NoResultsError)

  """
  def get_creative!(id), do: Repo.get!(Creative, id)

  @doc """
  Creates a creative.

  ## Examples

      iex> create_creative(%{field: value})
      {:ok, %Creative{}}

      iex> create_creative(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_creative(attrs \\ %{}) do
    %Creative{}
    |> Creative.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a creative.

  ## Examples

      iex> update_creative(creative, %{field: new_value})
      {:ok, %Creative{}}

      iex> update_creative(creative, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_creative(%Creative{} = creative, attrs) do
    creative
    |> Creative.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Creative.

  ## Examples

      iex> delete_creative(creative)
      {:ok, %Creative{}}

      iex> delete_creative(creative)
      {:error, %Ecto.Changeset{}}

  """
  def delete_creative(%Creative{} = creative) do
    Repo.delete(creative)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking creative changes.

  ## Examples

      iex> change_creative(creative)
      %Ecto.Changeset{source: %Creative{}}

  """
  def change_creative(%Creative{} = creative) do
    Creative.changeset(creative, %{})
  end



  defp filter_config(:templates) do
    defconfig do
      text :name
      text :slug
    end
  end

  defp filter_config(:themes) do
    defconfig do
      text :name
      text :slug
    end
  end

  defp filter_config(:creatives) do
    defconfig do
      text :name
    end
  end
end
