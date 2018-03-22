defmodule CodeSponsor.Schema.Creative do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeSponsor.Schema.Creative


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "creatives" do
    belongs_to :user, CodeSponsor.Schema.User
    has_many :sponsorships, CodeSponsor.Schema.Sponsorship
    field :name, :string
    field :body, :string
    field :image_url, :string

    timestamps()
  end

  @doc false
  def changeset(%Creative{} = creative, params) do
    creative
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(~w(name body image_url)a)
  end
end
