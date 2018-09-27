defmodule CodeFund.Repo.Migrations.AddWeekdaysOnlyToCampaigns do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :weekdays_only, :boolean, default: false
    end
  end
end
