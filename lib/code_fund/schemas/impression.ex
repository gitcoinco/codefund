defmodule CodeFund.Schema.Impression do
  use CodeFundWeb, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "impressions" do
    belongs_to(:campaign, CodeFund.Schema.Campaign)
    belongs_to(:distribution, CodeFund.Schema.Distribution)
    belongs_to(:property, CodeFund.Schema.Property)

    field(:ip, :string)
    field(:browser, :string)
    field(:city, :string)
    field(:country, :string)
    field(:device_type, :string)
    field(:browser_height, :integer)
    field(:browser_width, :integer)
    field(:latitude, :decimal)
    field(:longitude, :decimal)
    field(:os, :string)
    field(:postal_code, :string)
    field(:region, :string)
    field(:error_code, :integer)
    field(:revenue_amount, :decimal)
    field(:distribution_amount, :decimal)
    field(:user_agent, :string)
    field(:redirected_at, :naive_datetime)
    field(:redirected_to_url, :string)

    timestamps()
  end

  @doc false
  def changeset(%Impression{} = impression, params) do
    impression
    |> cast(params, __MODULE__.__schema__(:fields) |> List.delete(:id))
    |> validate_required(~w(property_id ip)a)
  end
end
