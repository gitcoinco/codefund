defmodule CodeSponsor.Properties.Property do
  use Ecto.Schema
  use Formex.Ecto.Schema
  import Ecto.Changeset
  alias CodeSponsor.Properties.Property


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "properties" do
    has_many :impressions, CodeSponsor.Impressions.Impression
    has_many :clicks, CodeSponsor.Clicks.Click
    belongs_to :sponsorship, CodeSponsor.Sponsorships.Sponsorship
    belongs_to :user, CodeSponsor.Coherence.User

    # This is used to tranfer legacy sponsored projects to the new system
    field :legacy_id, :string
    
    field :description, :string
    field :name, :string
    field :property_type, :integer
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(%Property{} = property, attrs) do
    property
    |> cast(attrs, [:user_id, :name, :url, :description, :property_type, :sponsorship_id])
    |> validate_required([:user_id, :name, :url, :property_type])
  end
end
