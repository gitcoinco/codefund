defmodule CodeFund.Repo.Migrations.AddRevenueOverrideRateToCampaigns do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :override_revenue_rate, :decimal, precision: 3, scale: 3
    end
  end
end
