defmodule CodeSponsor.Schema.Sponsorship  do
  use CodeSponsorWeb, :schema_with_formex

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sponsorships" do
    has_many :impressions, CodeSponsor.Schema.Impression
    has_many :clicks, CodeSponsor.Schema.Click
    belongs_to :property, CodeSponsor.Schema.Property
    belongs_to :campaign, CodeSponsor.Schema.Campaign
    belongs_to :creative, CodeSponsor.Schema.Creative

    field :redirect_url, :string
    field :bid_amount, :decimal
    field :override_revenue_rate, :decimal

    timestamps()
  end

  @doc false
  def changeset(%Sponsorship{} = sponsorship, params) do
    sponsorship
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(~w(bid_amount redirect_url)a)
    |> validate_format(:redirect_url, ~r/https?\:\/\/.*/)
  end
end
