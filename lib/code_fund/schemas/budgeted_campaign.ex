defmodule CodeFund.Schema.BudgetedCampaign do
  @moduledoc """
  This schema is for a postgres materialized view
  """

  use CodeFundWeb, :schema

  @primary_key false
  @foreign_key_type :binary_id
  schema "budgeted_campaigns" do
    belongs_to(:campaign, CodeFund.Schema.Campaign)
    belongs_to(:user, CodeFund.Schema.User)

    field(:total_spend, :decimal)
    field(:status, :integer)
    field(:campaign_name, :string)
    field(:target_ecpm, :decimal)
    field(:estimated_impressions, :integer)
    field(:revenue_amount, :decimal)
    field(:distribution_amount, :decimal)
    field(:total_impressions, :integer)
    field(:advertiser_company_name, :string)
    field(:audience_name, :string)
    field(:creative_name, :string)
    field(:balance, :decimal)
    field(:actual_ecpm, :decimal)
  end
end
