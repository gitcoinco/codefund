defmodule CodeFund.Schema.Impression do
  use CodeFundWeb, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "impressions" do
    belongs_to(:property, CodeFund.Schema.Property)
    belongs_to(:sponsorship, CodeFund.Schema.Sponsorship)
    belongs_to(:campaign, CodeFund.Schema.Campaign)

    field(:ip, :string)
    field(:browser, :string)
    field(:city, :string)
    field(:country, :string)
    field(:device_type, :string)
    field(:latitude, :decimal)
    field(:longitude, :decimal)
    field(:os, :string)
    field(:postal_code, :string)
    field(:region, :string)
    field(:user_agent, :string)

    timestamps()
  end

  @doc false
  def changeset(%Impression{} = impression, params) do
    impression
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(~w(property_id ip)a)
  end
end
