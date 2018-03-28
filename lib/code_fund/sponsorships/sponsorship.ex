defmodule CodeFund.Sponsorships.Sponsorship do
  use Ecto.Schema
  use Formex.Ecto.Schema
  import Ecto.Changeset
  alias CodeFund.Sponsorships.Sponsorship


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sponsorships" do
    has_many :impressions, CodeFund.Schema.Impression
    has_many :clicks, CodeFund.Schema.Click
    belongs_to :creative, CodeFund.Schema.Creative
    belongs_to :property, CodeFund.Schema.Property
    belongs_to :campaign, CodeFund.Schema.Campaign

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
