defmodule CodeSponsor.Repo.Migrations.CreateCampaigns do
  use Ecto.Migration

  def change do
    create table(:campaigns, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :redirect_url, :text, null: false
      add :status, :integer, default: 0, null: false
      add :description, :text
      add :daily_budget_cents, :integer, default: 0, null: false
      add :monthly_budget_cents, :integer, default: 0, null: false
      add :total_budget_cents, :integer, default: 0, null: false
      add :bid_amount_cents, :integer, default: 0, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:campaigns, [:user_id])
  end
end
