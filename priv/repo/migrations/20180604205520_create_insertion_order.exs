defmodule CodeFund.Repo.Migrations.CreateInsertionOrder do
  use Ecto.Migration

  def change do
    create table(:insertion_orders, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :impression_count, :integer, null: false
      add :billing_cycle, :naive_datetime, null: false

      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :audience_id, references(:audiences, on_delete: :nothing, type: :binary_id)
      timestamps()
    end
  end
end
