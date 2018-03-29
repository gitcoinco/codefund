defmodule CodeFund.Repo.Migrations.CreateProperties do
  use Ecto.Migration

  def change do
    create table(:properties, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :legacy_id, :string
      add :name, :string, null: false
      add :url, :text, null: false
      add :description, :text
      add :property_type, :integer, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:properties, [:user_id])
  end
end
