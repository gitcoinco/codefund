defmodule CodeFund.Repo.Migrations.KillClicksSponsorshipsBudgetedCampaigns do
  use Ecto.Migration

  def change do
    alter table(:impressions) do
      remove :sponsorship_id
    end

    alter table(:properties) do
      remove :sponsorship_id
    end
    drop table(:clicks)
    drop table(:sponsorships)

    execute "drop view budgeted_campaigns;"


  end
end
