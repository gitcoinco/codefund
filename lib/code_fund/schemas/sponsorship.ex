defmodule CodeFund.Schema.Sponsorship do
  use CodeFundWeb, :schema_with_formex

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sponsorships" do
    has_many(:impressions, CodeFund.Schema.Impression)
    has_many(:clicks, CodeFund.Schema.Click)
    belongs_to(:property, CodeFund.Schema.Property)
    belongs_to(:campaign, CodeFund.Schema.Campaign)
    belongs_to(:creative, CodeFund.Schema.Creative)

    field(:redirect_url, :string)
    field(:bid_amount, :decimal)
    field(:override_revenue_rate, :decimal)

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
