defmodule CodeFund.Schema.Creative do
  use Ecto.Schema
  import Ecto.Changeset
  import Framework.Ecto.Changeset.S3
  alias CodeFund.Schema.Creative
  import Validation.URL

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "creatives" do
    belongs_to(:user, CodeFund.Schema.User)
    has_many(:campaigns, CodeFund.Schema.Campaign)

    field(:name, :string)
    field(:headline, :string, default: "")
    field(:body, :string)
    field(:image_url, :string)
    field(:small_image, :any, virtual: true)
    field(:small_image_object, :string)
    field(:small_image_bucket, :string)
    field(:large_image, :any, virtual: true)
    field(:large_image_object, :string)
    field(:large_image_bucket, :string)

    timestamps()
  end

  @required [
    :name,
    :body,
    :image_url,
    :large_image_bucket,
    :large_image_object,
    :user_id
  ]

  def required, do: @required

  @doc false
  def changeset(%Creative{} = creative, params) do
    creative
    |> cast(
      params,
      (__MODULE__.__schema__(:fields) ++ [:small_image, :large_image]) |> List.delete(:id)
    )
    |> validate_url(:image_url)
    |> handle_s3_upload(:large_image)
    |> validate_required(@required)
    |> handle_s3_upload(:small_image)
  end
end
