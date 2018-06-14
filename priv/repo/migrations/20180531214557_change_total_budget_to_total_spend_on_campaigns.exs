defmodule CodeFund.Repo.Migrations.ChangeTotalBudgetToTotalSpendOnCampaigns do
  use Ecto.Migration

  def change do
    rename table("campaigns"), :budget_total_amount, to: :total_spend
    alter table("campaigns") do
      remove :budget_monthly_amount
    end
  end
end
