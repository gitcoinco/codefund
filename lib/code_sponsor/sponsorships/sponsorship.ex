defmodule CodeSponsor.Sponsorships.Sponsorship do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeSponsor.Sponsorships.Sponsorship


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sponsorships" do
    has_many :impressions, CodeSponsor.Impressions.Impression
    belongs_to :property, CodeSponsor.Properties.Property
    belongs_to :campaign, CodeSponsor.Campaigns.Campaign

    field :bid_amount_cents, Money.Ecto.Type
    
    timestamps()
  end

  @doc false
  def changeset(%Sponsorship{} = sponsorship, attrs) do
    sponsorship
    |> cast(attrs, [:bid_amount_cents])
    |> validate_required([:bid_amount_cents])
  end
end
