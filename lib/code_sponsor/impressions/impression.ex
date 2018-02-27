defmodule CodeSponsor.Impressions.Impression do
  use Ecto.Schema
  import Ecto.Changeset
  alias CodeSponsor.Impressions.Impression


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "impressions" do
    belongs_to :property, CodeSponsor.Properties.Property
    belongs_to :sponsorship, CodeSponsor.Sponsorships.Sponsorship
    belongs_to :campaign, CodeSponsor.Campaigns.Campaign

    field :bot, :boolean
    field :browser, :string
    field :city, :string
    field :country, :string
    field :device_type, :string
    field :ip, :string
    field :latitude, :decimal
    field :longitude, :decimal
    field :os, :string
    field :postal_code, :string
    field :region, :string
    field :screen_height, :integer
    field :screen_width, :integer
    field :user_agent, :string
    field :utm_campaign, :string
    field :utm_content, :string
    field :utm_medium, :string
    field :utm_source, :string
    field :utm_term, :string

    timestamps()
  end

  @doc false
  def changeset(%Impression{} = impression, attrs) do
    impression
    |> cast(attrs, [:ip, :user_agent, :browser, :os, :device_type, :screen_height, :screen_width, :country, :region, :city, :postal_code, :latitude, :longitude, :utm_source, :utm_medium, :utm_term, :utm_content, :utm_campaign])
    |> validate_required([:ip])
  end
end
