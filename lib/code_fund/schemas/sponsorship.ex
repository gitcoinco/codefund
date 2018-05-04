defmodule CodeFund.Schema.Sponsorship do
  use CodeFundWeb, :schema
  import Validation.URL

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required [:bid_amount, :redirect_url, :user_id]
  schema "sponsorships" do
    has_many(:impressions, CodeFund.Schema.Impression)
    has_many(:clicks, CodeFund.Schema.Click)
    belongs_to(:user, CodeFund.Schema.User)
    belongs_to(:property, CodeFund.Schema.Property)
    belongs_to(:campaign, CodeFund.Schema.Campaign)
    belongs_to(:creative, CodeFund.Schema.Creative)

    field(:redirect_url, :string)
    field(:bid_amount, :decimal)
    field(:override_revenue_rate, :decimal)

    timestamps()
  end

  def required, do: @required
  @doc false
  def changeset(%Sponsorship{} = sponsorship, params) do
    sponsorship
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(@required)
    |> validate_url(:redirect_url)
  end
end
