defmodule CodeFund.Schema.Property do
  use CodeFundWeb, :schema
  import Validation.URL

  @property_types %{
    website: 1,
    repository: 2,
    newsletter: 3
  }

  @required [
    :name,
    :url,
    :property_type,
    :status,
    :user_id,
    :slug
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "properties" do
    has_many(:impressions, CodeFund.Schema.Impression)
    belongs_to(:user, CodeFund.Schema.User)
    belongs_to(:audience, CodeFund.Schema.Audience)
    belongs_to(:template, CodeFund.Schema.Template)

    # This is used to tranfer legacy sponsored projects to the new system
    field(:legacy_id, :string)
    field(:description, :string)
    field(:name, :string)
    field(:slug, :string)
    field(:property_type, :integer, default: 1)
    field(:url, :string)
    field(:estimated_monthly_page_views, :integer)
    field(:estimated_monthly_visitors, :integer)
    field(:alexa_site_rank, :integer)
    field(:language, :string)
    field(:programming_languages, {:array, :string})
    field(:topic_categories, {:array, :string})
    field(:screenshot_url, :string)
    field(:status, :integer, default: 0)
    field(:excluded_advertisers, {:array, :string})
    timestamps()
  end

  def required, do: @required

  @doc false
  def changeset(%Property{} = property, params) do
    property
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> update_slug()
    |> validate_required(@required)
    |> unique_constraint(:slug)
    |> validate_url(:url)
    |> validate_url(:screenshot_url)
  end

  defp update_slug(%Ecto.Changeset{changes: %{name: name}} = changeset) do
    case from(p in __MODULE__, select: count(p.id), where: p.slug == ^slugify(name))
         |> CodeFund.Repo.one() do
      0 ->
        changeset
        |> put_change(:slug, slugify(name))

      count ->
        changeset
        |> put_change(:slug, "#{slugify(name)}_#{count + 1}")
    end
  end

  defp update_slug(changeset), do: changeset

  defp slugify(nil), do: UUID.uuid4()

  defp slugify(field_to_base_slug_on) do
    field_to_base_slug_on
    |> Macro.underscore()
    |> String.replace(~r/\(|\//, "_")
    |> String.replace(~r/-| |\)/, "")
  end

  def property_types, do: @property_types
end
