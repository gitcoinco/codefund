defmodule CodeSponsor.Schema.Sponsorship  do
  use CodeSponsorWeb, :schema_with_formex

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sponsorships" do
    has_many :impressions, CodeSponsor.Schema.Impression
    has_many :clicks, CodeSponsor.Schema.Click
    belongs_to :property, CodeSponsor.Schema.Property
    belongs_to :campaign, CodeSponsor.Schema.Campaign

    field :redirect_url, :string
    field :bid_amount, :decimal
    field :override_revenue_rate, :decimal

    timestamps()
  end

  @required [:bid_amount, :redirect_url]

  @doc false
  def changeset(%Sponsorship{} = sponsorship, params) do
    sponsorship
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(@required)
    |> validate_format(:redirect_url, ~r/https?\:\/\/.*/)
  end
end
