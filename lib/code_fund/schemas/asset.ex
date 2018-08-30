defmodule CodeFund.Schema.Asset do
  use CodeFundWeb, :schema
  import Framework.Ecto.Changeset.S3

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "assets" do
    belongs_to(:user, CodeFund.Schema.User)
    field(:name, :string)
    field(:image, :any, virtual: true)
    field(:image_object, :string)
    field(:image_bucket, :string)

    timestamps()
  end

  @required [
    :name,
    :image_object,
    :image_bucket
  ]

  def required, do: @required

  @doc false
  def changeset(%__MODULE__{} = asset, params) do
    asset
    |> cast(
      params,
      (__MODULE__.__schema__(:fields) ++ [:image]) |> List.delete(:id)
    )
    |> handle_s3_upload(:image)
    |> validate_required(@required)
  end
end
