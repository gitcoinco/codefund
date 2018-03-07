defmodule CodeSponsor.Sponsorships.Sponsorship do
  use Ecto.Schema
  use Formex.Ecto.Schema
  import Ecto.Changeset
  alias CodeSponsor.Sponsorships.Sponsorship


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sponsorships" do
    has_many :impressions, CodeSponsor.Impressions.Impression
    has_many :clicks, CodeSponsor.Clicks.Click
    has_many :sponsorships, CodeSponsor.Sponsorships.Sponsorship
    belongs_to :property, CodeSponsor.Properties.Property
    belongs_to :campaign, CodeSponsor.Campaigns.Campaign

    field :redirect_url, :string
    field :bid_amount, :decimal
    
    timestamps()
  end

  @attrs [:bid_amount, :redirect_url]
  @required [:bid_amount]

  @doc false
  def changeset(%Sponsorship{} = sponsorship, attrs) do
    sponsorship
    |> cast(attrs, @attrs)
    |> validate_required(@required)
  end
end
