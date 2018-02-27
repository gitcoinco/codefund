defmodule CodeSponsor.Properties.Property do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeSponsor.Properties.Property


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "properties" do
    has_many :impressions, CodeSponsor.Impressions.Impression
    has_many :clicks, CodeSponsor.Clicks.Click
    belongs_to :sponsorship, CodeSponsor.Sponsorships.Sponsorship
    belongs_to :user, CodeSponsor.Coherence.User

    field :description, :string
    field :name, :string
    field :property_type, :integer
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(%Property{} = property, attrs) do
    property
    |> cast(attrs, [:name, :url, :description, :property_type, :sponsorship_id])
    |> validate_required([:name, :url, :property_type])
  end
end
