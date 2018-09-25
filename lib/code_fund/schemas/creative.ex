defmodule CodeFund.Schema.Creative do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeFund.Schema.Creative

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "creatives" do
    belongs_to(:user, CodeFund.Schema.User)
    belongs_to(:large_image_asset, CodeFund.Schema.Asset)
    belongs_to(:small_image_asset, CodeFund.Schema.Asset)
    belongs_to(:wide_image_asset, CodeFund.Schema.Asset)
    has_many(:campaigns, CodeFund.Schema.Campaign)

    field(:name, :string)
    field(:headline, :string, default: "")
    field(:body, :string)

    timestamps()
  end

  @required [
    :name,
    :body,
    :small_image_asset_id,
    :large_image_asset_id,
    :user_id
  ]

  def required, do: @required

  @doc false
  def changeset(%Creative{} = creative, params) do
    creative
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(@required)
  end
end
