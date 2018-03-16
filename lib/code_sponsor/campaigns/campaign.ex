defmodule CodeSponsor.Campaigns.Campaign do
  use Ecto.Schema
  use Formex.Ecto.Schema
  import Ecto.Changeset
  alias CodeSponsor.Campaigns.Campaign

  
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "campaigns" do
    has_many :impressions, CodeSponsor.Impressions.Impression
    has_many :clicks, CodeSponsor.Clicks.Click
    belongs_to :user, CodeSponsor.Coherence.User
    
    field :name, :string
    field :redirect_url, :string
    field :status, :integer, default: 1
    field :description, :string
    field :bid_amount, :decimal, default: Decimal.new(0.0)
    field :budget_daily_amount, :decimal, default: Decimal.new(0.0)
    field :budget_monthly_amount, :decimal, default: Decimal.new(0.0)
    field :budget_total_amount, :decimal, default: Decimal.new(0.0)
    field :fraud_check_url, :string

    timestamps()
  end

  @attrs [
    :user_id,
    :name,
    :redirect_url,
    :status,
    :description,
    :bid_amount,
    :budget_daily_amount,
    :budget_monthly_amount,
    :budget_total_amount,
    :fraud_check_url
  ]

  @required [
    :user_id,
    :name,
    :redirect_url,
    :status,
    :bid_amount,
    :budget_daily_amount,
    :budget_monthly_amount,
    :budget_total_amount
  ]

  @doc false
  def changeset(%Campaign{} = campaign, attrs) do
    campaign
    |> cast(attrs, @attrs)
    |> validate_required(@required)
  end
end
