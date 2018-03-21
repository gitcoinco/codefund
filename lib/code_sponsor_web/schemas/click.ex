defmodule CodeSponsor.Schema.Click do
  use CodeSponsorWeb, :schema_with_formex
  import CodeSponsor.Constants

  const :statuses, %{
    pending:     0,
    redirected:  1,
    fraud_check: 2,
    bot:         100,
    duplicate:   101,
    fraud:       102,
    no_sponsor:  103
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clicks" do
    belongs_to :property, CodeSponsor.Schema.Property
    belongs_to :sponsorship, CodeSponsor.Schema.Sponsorship
    belongs_to :campaign, CodeSponsor.Schema.Campaign

    field :status, :integer, default: 0
    field :is_bot, :boolean, default: false
    field :is_duplicate, :boolean, default: false
    field :is_fraud, :boolean, default: false
    field :browser, :string
    field :city, :string
    field :country, :string
    field :device_type, :string
    field :ip, :string
    field :landing_page, :string
    field :latitude, :decimal
    field :longitude, :decimal
    field :os, :string
    field :postal_code, :string
    field :referrer, :string
    field :referring_domain, :string
    field :region, :string
    field :screen_height, :integer
    field :screen_width, :integer
    field :search_keyword, :string
    field :user_agent, :string
    field :utm_campaign, :string
    field :utm_content, :string
    field :utm_medium, :string
    field :utm_source, :string
    field :utm_term, :string
    field :revenue_amount, :decimal
    field :distribution_amount, :decimal
    field :fraud_check_redirected_at, :naive_datetime

    timestamps()
  end

  @required [
    :status,
    :property_id,
    :ip,
    :revenue_amount,
    :distribution_amount
  ]

  @doc false
  def changeset(%Click{} = click, params) do
    click
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(@required)
  end
end
