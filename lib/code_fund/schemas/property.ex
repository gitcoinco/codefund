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
    :programming_languages,
    :topic_categories,
    :language
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "properties" do
    has_many(:impressions, CodeFund.Schema.Impression)
    has_many(:clicks, CodeFund.Schema.Click)
    belongs_to(:sponsorship, CodeFund.Schema.Sponsorship)
    belongs_to(:user, CodeFund.Schema.User)

    # This is used to tranfer legacy sponsored projects to the new system
    field(:legacy_id, :string)
    field(:description, :string)
    field(:name, :string)
    field(:property_type, :integer)
    field(:url, :string)
    field(:estimated_monthly_page_views, :integer)
    field(:estimated_monthly_visitors, :integer)
    field(:alexa_site_rank, :integer)
    field(:language, :string)
    field(:programming_languages, {:array, :string})
    field(:topic_categories, {:array, :string})
    field(:screenshot_url, :string)
    field(:status, :integer, default: 0)
    timestamps()
  end

  def required, do: @required

  @doc false
  def changeset(%Property{} = property, params) do
    property
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(@required)
    |> validate_length(:programming_languages, min: 1)
    |> validate_length(:topic_categories, min: 1)
    |> validate_url(:url)
    |> validate_url(:screenshot_url)
  end

  def property_types, do: @property_types
end
