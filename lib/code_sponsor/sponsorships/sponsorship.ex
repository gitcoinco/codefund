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
    belongs_to :creative, CodeSponsor.Creatives.Creative
    belongs_to :property, CodeSponsor.Properties.Property
    belongs_to :campaign, CodeSponsor.Campaigns.Campaign

    field :redirect_url, :string
    field :bid_amount, :decimal
    field :override_revenue_rate, :decimal
    
    timestamps()
  end

  @attrs [:bid_amount, :redirect_url, :override_revenue_rate]
  @required [:bid_amount, :redirect_url]

  @doc false
  def changeset(%Sponsorship{} = sponsorship, attrs) do
    sponsorship
    |> cast(attrs, @attrs)
    |> validate_required(@required)
    |> validate_format(:redirect_url, ~r/https?\:\/\/.*/)
  end
end
