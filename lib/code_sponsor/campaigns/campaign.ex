defmodule CodeSponsor.Campaigns.Campaign do
  use Ecto.Schema
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
    field :bid_amount_cents, Money.Ecto.Type
    field :daily_budget_cents, Money.Ecto.Type
    field :monthly_budget_cents, Money.Ecto.Type
    field :total_budget_cents, Money.Ecto.Type

    timestamps()
  end

  @doc false
  def changeset(%Campaign{} = campaign, attrs) do
    campaign
    |> cast(attrs, [:name, :redirect_url, :status, :description, :daily_budget_cents, :monthly_budget_cents, :total_budget_cents, :bid_amount_cents])
    |> validate_required([:name, :redirect_url, :status, :daily_budget_cents, :monthly_budget_cents, :total_budget_cents, :bid_amount_cents])
  end
end
