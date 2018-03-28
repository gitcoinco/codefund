defmodule CodeFund.Schema.BudgetedCampaign do
  @moduledoc """
  This schema is for a postgres view
  """

  use CodeFundWeb, :schema

  @primary_key false
  @foreign_key_type :binary_id
  schema "budgeted_campaigns" do
    belongs_to :campaign, CodeFund.Schema.Campaign

    field :day_spend, :decimal
    field :month_spend, :decimal
    field :total_spend, :decimal
    field :day_remain, :decimal
    field :month_remain, :decimal
    field :total_remain, :decimal
  end
end
