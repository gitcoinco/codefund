defmodule CodeFund.Schema.Creative do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeFund.Schema.Creative
  import Validation.URL

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "creatives" do
    belongs_to(:user, CodeFund.Schema.User)
    has_many(:sponsorships, CodeFund.Schema.Sponsorship)
    field(:name, :string)
    field(:body, :string)
    field(:image_url, :string)

    timestamps()
  end

  @required [
    :name,
    :body,
    :image_url
  ]

  def required, do: @required

  @doc false
  def changeset(%Creative{} = creative, params) do
    creative
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_url(:image_url)
    |> validate_required(@required)
  end
end
