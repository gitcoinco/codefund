defmodule CodeSponsor.Creatives.Creative do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeSponsor.Creatives.Creative


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "creatives" do
    belongs_to :user, CodeSponsor.Coherence.User
    has_many :sponsorships, CodeSponsor.Sponsorships.Sponsorship
    field :name, :string
    field :body, :string
    field :image_url, :string

    timestamps()
  end

  @attrs [:name, :body, :image_url]
  @required [:name, :body, :image_url]

  @doc false
  def changeset(%Creative{} = creative, attrs) do
    creative
    |> cast(attrs, @attrs)
    |> validate_required(@required)
  end
end
