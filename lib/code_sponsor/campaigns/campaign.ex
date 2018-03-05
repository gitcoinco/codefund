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
    field :status, :integer
    field :description, :string
    field :bid, :decimal
    field :budget_daily, :decimal
    field :budget_monthly, :decimal
    field :budget_total, :decimal

    timestamps()
  end

  @attrs [
    :user_id,
    :name,
    :redirect_url,
    :status,
    :description,
    :bid,
    :budget_daily,
    :budget_monthly,
    :budget_total
  ]

  @required_fields [
    :user_id,
    :name,
    :redirect_url,
    :status,
    :bid,
    :budget_daily,
    :budget_monthly,
    :budget_total
  ]

  @doc false
  def changeset(%Campaign{} = campaign, attrs) do
    campaign
    |> cast(attrs, @attrs)
    |> validate_required(@required)
  end
end
