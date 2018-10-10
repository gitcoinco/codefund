defmodule CodeFund.Templates do
  import CodeFund.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config
  import Ecto.Query, warn: false
  alias CodeFund.Repo
  alias CodeFund.Schema.Template
  alias CodeFund.Schema.Property

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Returns the list of templates.

  ## Examples

      iex> list_templates()
      [%Template{}, ...]

  """
  def list_templates do
    from(t in Template, order_by: fragment("lower(?)", t.name))
    |> Repo.all()
    |> Repo.preload([:themes])
  end

  #
  @doc """
  Paginate the list of templates using filtrex filters.
  """
  def paginate_templates(_user, params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <-
           Filtrex.parse_params(filter_config(:templates), params["template"] || %{}),
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
       }}
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

  def slug_for_property_id(property_id, requested_template_slug) when not is_nil(property_id) do
    from(
      t in Template,
      join: p in Property,
      on: p.template_id == t.id,
      where: p.id == ^property_id
    )
    |> Repo.one()
    |> return_template_slug(requested_template_slug)
  end

  def slug_for_property_id(_, requested_template_slug) do
    return_template_slug(nil, requested_template_slug)
  end

  defp return_template_slug(%Template{slug: slug}, _requested_template_slug)
       when not is_nil(slug),
       do: slug

  defp return_template_slug(_, requested_template_slug) when not is_nil(requested_template_slug),
    do: requested_template_slug

  defp return_template_slug(_, _), do: "default"

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

  defp filter_config(:templates) do
    defconfig do
      text(:name)
      text(:slug)
    end
  end
end
