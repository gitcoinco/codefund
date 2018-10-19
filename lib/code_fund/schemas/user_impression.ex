defmodule CodeFund.Schema.UserImpression do
  use CodeFundWeb, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "user_impressions" do
    field(:campaign_id, :binary_id)
    field(:campaign_user_id, :binary_id)
    field(:property_user_id, :binary_id)
    field(:advertiser_company_name, :string)
    field(:campaign_name, :string)
    field(:country, :string)
    field(:distribution_amount, :decimal)
    field(:house_ad, :boolean)
    field(:property_name, :string)
    field(:redirected_at, :naive_datetime)
    field(:revenue_amount, :decimal)
  end
end
