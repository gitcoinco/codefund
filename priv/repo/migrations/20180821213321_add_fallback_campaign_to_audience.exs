defmodule CodeFund.Repo.Migrations.AddFallbackCampaignToAudience do
  use Ecto.Migration

  def change do
    alter table(:audiences) do
      add :fallback_campaign_id, references(:campaigns, type: :binary_id, column: :id)
    end
  end
end
