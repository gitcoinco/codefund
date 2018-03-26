
defmodule CodeSponsor.CampaignBudgets do
  @moduledoc """
  Mutations and queries around campaign budgets
  """

  use CodeSponsorWeb, :query

  def spent_daily_budget(%CodeSponsor.Schema.Campaign{} = campaign, timezone \\ "UTC") do
    start_date = Timex.now(timezone) |> Timex.beginning_of_day
    end_date   = Timex.now(timezone) |> Timex.end_of_day
    spent_budget(campaign, start_date, end_date)
  end

  def spent_monthly_budget(%CodeSponsor.Schema.Campaign{} = campaign, timezone \\ "UTC") do
    start_date = Timex.now(timezone) |> Timex.beginning_of_month
    end_date   = Timex.now(timezone) |> Timex.end_of_month
    spent_budget(campaign, start_date, end_date)
  end

  def spent_total_budget(%CodeSponsor.Schema.Campaign{} = campaign, timezone \\ "UTC") do
    start_date = Timex.now(timezone) |> Timex.shift(years: -20) |> Timex.end_of_month
    end_date   = Timex.now(timezone) |> Timex.end_of_month
    spent_budget(campaign, start_date, end_date)
  end

  def spent_budget(%CodeSponsor.Schema.Campaign{} = campaign, start_date, end_date) do
    results =
      CodeSponsor.Schema.Click
      |> by_date_range(start_date, end_date)
      |> select_amounts(campaign)
      |> Repo.one()

    results.total_revenue_amount || Decimal.new(0.0)
  end

  @doc """
  Returns the amounts for payable ads on a given campaign.

  ## Examples

      iex> select_amounts(campaign)
      %{
        total_distribution_amount: #Decimal<1723.65>,
        total_revenue_amount: #Decimal<3447.30>
      }

  """
  def select_amounts(query, %CodeSponsor.Schema.Campaign{} = campaign) do
    from c in query,
      where: [
        is_bot: false,
        is_duplicate: false,
        is_fraud: false,
        campaign_id: ^campaign.id
      ],
      select: %{
        total_revenue_amount: sum(c.revenue_amount),
        total_distribution_amount: sum(c.distribution_amount)
      }
  end

  def by_date_range(query, %DateTime{} = start_date, %DateTime{} = end_date) do
    from c in query,
      where: c.inserted_at >= ^start_date,
      where: c.inserted_at <= ^end_date
  end
end
