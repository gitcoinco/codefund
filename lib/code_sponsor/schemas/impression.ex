defmodule CodeSponsor.Schema.Impression  do
  use CodeSponsorWeb, :schema_with_formex

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "impressions" do
    belongs_to :property, CodeSponsor.Schema.Property
    belongs_to :sponsorship, CodeSponsor.Schema.Sponsorship
    belongs_to :campaign, CodeSponsor.Schema.Campaign

    field :ip, :string
    field :is_bot, :boolean, default: false
    field :browser, :string
    field :city, :string
    field :country, :string
    field :device_type, :string
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
  def changeset(%Impression{} = impression, params) do
    impression
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(~w(property_id ip)a)
  end
end
