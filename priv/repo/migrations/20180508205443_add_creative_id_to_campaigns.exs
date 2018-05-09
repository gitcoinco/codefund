defmodule CodeFund.Repo.Migrations.AddCreativeIdToCampaigns do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :creative_id, references(:creatives, on_delete: :nothing, type: :binary_id)
    end
  end
end
