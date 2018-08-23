defmodule CodeFund.Repo.Migrations.AddUsHoursOnlyToCampaigns do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :us_hours_only, :boolean, default: false
    end
  end
end
