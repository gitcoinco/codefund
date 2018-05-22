defmodule CodeFund.Schema.Audience do
  use CodeFundWeb, :schema

  alias CodeFund.Schema.{User}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "audiences" do
    belongs_to(:user, User)

    field(:name, :string)
    field(:programming_languages, {:array, :string}, default: [])
    field(:topic_categories, {:array, :string}, default: [])
    field(:excluded_countries, {:array, :string}, default: [])

    timestamps()
  end

  @required [
    :name,
    :user_id
  ]

  def required, do: @required

  @doc false
  def changeset(%Audience{} = audience, params) do
    audience
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(@required)
  end
end
