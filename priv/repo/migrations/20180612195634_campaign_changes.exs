defmodule CodeFund.Repo.Migrations.CampaignChanges do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      remove :fraud_check_url
      remove :description

      add :start_date, :naive_datetime
      add :end_date, :naive_datetime
    end
  end
end
