defmodule CodeFund.Schema.Campaign do
  use CodeFundWeb, :schema
  import Validation.URL

  alias CodeFund.Schema.{Audience, Impression, Click, BudgetedCampaign, User, Sponsorship}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "campaigns" do
    has_many(:impressions, Impression)
    has_many(:clicks, Click)
    has_many(:sponsorships, Sponsorship)
    has_one(:budgeted_campaign, BudgetedCampaign)
    belongs_to(:audience, Audience)
    belongs_to(:user, User)

    field(:name, :string)
    field(:redirect_url, :string)
    field(:status, :integer, default: 1)
    field(:description, :string)
    field(:bid_amount, :decimal, default: Decimal.new(0.0))
    field(:budget_daily_amount, :decimal, default: Decimal.new(0.0))
    field(:budget_monthly_amount, :decimal, default: Decimal.new(0.0))
    field(:budget_total_amount, :decimal, default: Decimal.new(0.0))
    field(:fraud_check_url, :string)

    timestamps()
  end

  @required [
    :name,
    :audience_id,
    :redirect_url,
    :status,
    :bid_amount,
    :budget_daily_amount,
    :budget_monthly_amount,
    :budget_total_amount,
    :user_id
  ]

  def required, do: @required

  @doc false
  def changeset(%Campaign{} = campaign, params) do
    campaign
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(@required)
    |> validate_url(:redirect_url)
    |> validate_url(:fraud_check_url)
  end
end
