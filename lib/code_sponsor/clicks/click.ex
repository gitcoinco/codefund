defmodule CodeSponsor.Clicks.Click do
  use Ecto.Schema
  use Formex.Ecto.Schema
  import Ecto.Changeset
  alias CodeSponsor.Clicks.Click
  import CodeSponsor.Constants

  const :statuses, %{
    pending:    0,
    redirected: 1,
    bot:        100,
    duplicate:  101,
    fraud:      102,
    no_sponsor: 103
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clicks" do
    belongs_to :property, CodeSponsor.Properties.Property
    belongs_to :sponsorship, CodeSponsor.Sponsorships.Sponsorship
    belongs_to :campaign, CodeSponsor.Campaigns.Campaign

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

    timestamps()
  end

  @attrs [
    :status,
    :property_id,
    :sponsorship_id,
    :campaign_id,
    :ip,
    :user_agent,
    :is_bot,
    :is_duplicate,
    :is_fraud,
    :referrer,
    :landing_page,
    :referring_domain,
    :search_keyword,
    :browser,
    :os,
    :device_type,
    :screen_height,
    :screen_width,
    :country,
    :region,
    :city,
    :postal_code,
    :latitude,
    :longitude,
    :utm_source,
    :utm_medium,
    :utm_term,
    :utm_content,
    :utm_campaign,
    :revenue_amount,
    :distribution_amount
  ]

  @required [
    :status,
    :property_id,
    :ip,
    :revenue_amount,
    :distribution_amount
  ]

  @doc false
  def changeset(%Click{} = click, attrs) do
    click
    |> cast(attrs, @attrs)
    |> validate_required(@required)
  end
end
