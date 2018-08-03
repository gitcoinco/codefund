defmodule CodeFund.Properties do
  @moduledoc """
  The Properties context.
  """

  use CodeFundWeb, :query

  alias CodeFund.Schema.{Property, User}

  @programming_languages [
    "Java",
    "C",
    "C++",
    "C#",
    "Python",
    "Visual Basic .NET",
    "PHP",
    "JavaScript",
    "Delphi/Object Pascal",
    "Swift",
    "Perl",
    "Ruby",
    "Assembly language",
    "R",
    "Visual Basic",
    "Objective-C",
    "Go",
    "MATLAB",
    "PL/SQL",
    "Scratch",
    "SAS",
    "D",
    "Dart",
    "ABAP",
    "COBOL",
    "Ada",
    "Fortran",
    "Transact-SQL",
    "Lua",
    "Scala",
    "Logo",
    "F#",
    "Lisp",
    "LabVIEW",
    "Prolog",
    "Haskell",
    "Scheme",
    "Groovy",
    "RPG (OS/400)",
    "Apex",
    "Erlang",
    "MQL4",
    "Rust",
    "Bash",
    "Ladder Logic",
    "Q",
    "Julia",
    "Alice",
    "VHDL",
    "Awk",
    "Other"
  ]

  @topic_categories [
    "Frontend Concepts",
    "Frontend Frameworks & Tools",
    "Frontend Workflow & Tooling",
    "React",
    "HTML5",
    "CSS & Design",
    "Languages & Frameworks",
    "Database",
    "Backend Services",
    "Dev Ops",
    "Shell",
    "Git",
    "Docker",
    "Hybrid & Mobile Web",
    "IOS Development",
    "Android Development",
    "Game Development",
    "Resources",
    "Computer Science",
    "Blockchain"
  ]

  @languages [
    "Albanian",
    "Armenian",
    "Pashto",
    "Azeri",
    "Bosnian",
    "Bulgarian",
    "Belarusian",
    "Chinese",
    "Czech",
    "German",
    "Danish",
    "Estonian",
    "Spanish",
    "Galician",
    "Finnish",
    "Faroese",
    "French",
    "English",
    "Georgian",
    "Greek",
    "Croatian",
    "Hungarian",
    "Indonesian",
    "Hebrew",
    "Hindi",
    "Farsi",
    "Icelandic",
    "Italian",
    "Japanese",
    "Swahili",
    "Kyrgyz",
    "Korean",
    "Kazakh",
    "Lithuanian",
    "Latvian",
    "FYRO Macedonian",
    "Mongolian",
    "Maltese",
    "Divehi",
    "Malay",
    "Dutch",
    "Norwegian",
    "Maori",
    "Tagalog",
    "Urdu",
    "Polish",
    "Portuguese",
    "Romanian",
    "Russian",
    "Swedish",
    "Slovenian",
    "Slovak",
    "Serbian",
    "Syriac",
    "Thai",
    "Turkish",
    "Ukrainian",
    "Uzbek",
    "Vietnamese",
    "Zulu"
  ]

  def programming_languages do
    @programming_languages
    |> Enum.chunk_every(1)
    |> Enum.map(fn [a] -> {a, a} end)
  end

  def topic_categories do
    @topic_categories
    |> Enum.chunk_every(1)
    |> Enum.map(fn [a] -> {a, a} end)
  end

  def languages do
    @languages
    |> Enum.sort()
    |> Enum.chunk_every(1)
    |> Enum.map(fn [a] -> {a, a} end)
  end

  @pagination [page_size: 15]
  @pagination_distance 5

  @statuses [
    Pending: 0,
    Active: 1,
    Rejected: 2,
    Archived: 3,
    Blacklisted: 4
  ]

  def statuses, do: @statuses

  @doc """
  Paginate the list of properties using filtrex filters.
  """
  def paginate_properties(%User{} = user, params \\ %{}) do
    property_params =
      case params |> Map.get("property") do
        params = %{} ->
          params
          |> Map.to_list()
          |> Enum.reject(fn {_, v} -> v == "" end)
          |> Enum.into(%{})

        nil ->
          %{}
      end

    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:properties), property_params),
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
       }}
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  defp do_paginate_properties(%User{} = user, filter, params) do
    case Enum.member?(user.roles, "admin") do
      true ->
        Property
        |> preload([:user, :audience, :template])
        |> Filtrex.query(filter)
        |> order_by(^sort(params))
        |> paginate(Repo, params, @pagination)

      false ->
        Property
        |> preload([:user, :audience, :template])
        |> Filtrex.query(filter)
        |> where([p], p.user_id == ^user.id)
        |> order_by(^sort(params))
        |> paginate(Repo, params, @pagination)
    end
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

  @spec list_active_properties() :: [Ecto.Schema.t()]
  def list_active_properties do
    Repo.all(
      from(
        p in Property,
        where: p.status == 1,
        where: p.property_type == 1,
        order_by: fragment("lower(?)", p.name)
      )
    )
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
        {:ok, _} ->
          Repo.get!(Property, id) |> Repo.preload([:user, :audience, :template])

        :error ->
          Repo.get_by!(Property, legacy_id: id) |> Repo.preload([:user, :audience, :template])
      end
    rescue
      Ecto.NoResultsError ->
        Repo.get_by!(Property, legacy_id: id) |> Repo.preload([:user, :audience, :template])
    end
  end

  def get_property_by_name!(name),
    do: Repo.get_by!(Property, name: name) |> Repo.preload([:user, :audience, :template])

  def get_all_display_rates(%Property{audience: audience}) when not is_nil(audience) do
    AdService.Query.ForDisplay.build(audience, nil)
    |> CodeFund.Repo.all()
    |> AdService.Math.Basic.get_all_display_rates()
  end

  def get_all_display_rates(%Property{audience: nil}), do: []

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

  @spec update_excluded_advertisers(Ecto.Changeset.t()) :: :ok
  def update_excluded_advertisers(%Ecto.Changeset{
        data: %CodeFund.Schema.User{} = data,
        changes: changes
      }) do
    case :company in Map.keys(changes) do
      true ->
        data.company
        |> update_or_remove_advertiser(changes.company)
        |> Repo.update_all([])

        :ok

      false ->
        :ok
    end
  end

  defp update_or_remove_advertiser(old_name, nil) do
    from(
      p in Property,
      update: [
        set: [
          excluded_advertisers: fragment("array_remove(excluded_advertisers, ?)", ^old_name)
        ]
      ],
      where: ^old_name in p.excluded_advertisers
    )
  end

  defp update_or_remove_advertiser(old_name, new_name) do
    from(
      p in Property,
      update: [
        set: [
          excluded_advertisers:
            fragment("array_replace(excluded_advertisers, ?, ?)", ^old_name, ^new_name)
        ]
      ],
      where: ^old_name in p.excluded_advertisers
    )
  end

  defp filter_config(:properties) do
    defconfig do
      text(:name)
      text(:url)
      text(:description)
      number(:status)
      text(:audience_id)
    end
  end
end
