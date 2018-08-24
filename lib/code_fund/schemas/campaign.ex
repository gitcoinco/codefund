defmodule CodeFund.Schema.Campaign do
  use CodeFundWeb, :schema
  import Validation.URL
  import Framework.Ecto.Changeset.Date

  alias CodeFund.Schema.{
    Audience,
    BudgetedCampaign,
    Campaign,
    Creative,
    Impression,
    User
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "campaigns" do
    has_many(:impressions, Impression)
    has_one(:campaign, Campaign, foreign_key: :fallback_campaign_id)
    has_one(:budgeted_campaign, BudgetedCampaign)
    belongs_to(:audience, Audience)
    belongs_to(:creative, Creative)
    belongs_to(:user, User)

    field(:name, :string)
    field(:redirect_url, :string)
    field(:status, :integer, default: 1)
    field(:ecpm, :decimal, default: Decimal.new(0.0))
    field(:included_countries, {:array, :string}, default: [])
    field(:impression_count, :integer)
    field(:budget_daily_amount, :decimal, default: Decimal.new(0.0))
    field(:total_spend, :decimal, default: Decimal.new(0.0))
    field(:start_date, :naive_datetime)
    field(:end_date, :naive_datetime)
    field(:us_hours_only, :boolean)

    timestamps()
  end

  @required [
    :name,
    :creative_id,
    :redirect_url,
    :status,
    :ecpm,
    :start_date,
    :end_date,
    :impression_count,
    :budget_daily_amount,
    :total_spend,
    :user_id
  ]

  def required, do: @required

  @doc false
  def changeset(%Campaign{} = campaign, params) do
    campaign
    |> cast(params, __MODULE__.__schema__(:fields) -- [:id, :start_date, :end_date])
    |> cast_dates(params, [:start_date, :end_date])
    |> validate_required(@required)
    |> validate_url(:redirect_url)
    |> foreign_key_constraint(:creative_id)
  end
end
