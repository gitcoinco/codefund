defmodule CodeFund.Repo.Migrations.CreateAssetsTable do
  use Ecto.Migration

  def change do
    create table(:assets, primary_key: false) do
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :image_object, :string, null: false
      add :image_bucket, :string, null: false
      timestamps()
    end

    create index(:assets, [:user_id])
  end
end
