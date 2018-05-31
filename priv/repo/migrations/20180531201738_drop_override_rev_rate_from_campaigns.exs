defmodule CodeFund.Repo.Migrations.DropOverrideRevRateFromCampaigns do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      remove :override_revenue_rate
    end
  end
end
