defmodule CodeSponsor.Repo.Migrations.CreateCampaigns do
  use Ecto.Migration

  def change do
    create table(:campaigns, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :redirect_url, :text, null: false
      add :status, :integer, default: 0, null: false
      add :description, :text
      add :bid, :decimal, precision: 10, scale: 2, null: false
      add :budget_daily, :decimal, precision: 10, scale: 2, null: false
      add :budget_monthly, :decimal, precision: 10, scale: 2, null: false
      add :budget_total, :decimal, precision: 10, scale: 2, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:campaigns, [:user_id])
  end
end
