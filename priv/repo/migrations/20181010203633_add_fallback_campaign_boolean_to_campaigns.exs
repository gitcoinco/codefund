defmodule CodeFund.Repo.Migrations.AddFallbackCampaignBooleanToCampaigns do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :fallback_campaign, :boolean, default: false, null: false
    end
  end
end
