defmodule CodeFund.Schema.Audience do
  use CodeFundWeb, :schema
  alias CodeFund.Schema.Campaign

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "audiences" do
    belongs_to(:campaigns, Campaign, foreign_key: :fallback_campaign_id, define_field: false)

    field(:fallback_campaign_id, Ecto.UUID)
    field(:name, :string)
    field(:programming_languages, {:array, :string}, default: [])
    field(:topic_categories, {:array, :string}, default: [])

    timestamps()
  end

  @required [
    :name
  ]

  def required, do: @required

  @doc false
  def changeset(%Audience{} = audience, params) do
    audience
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(@required)
  end
end
