defmodule CodeFund.Repo.Migrations.CreateCreatives do
  use Ecto.Migration

  def change do
    create table(:creatives, primary_key: false) do
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :body, :string
      add :image_url, :string

      timestamps()
    end

    create index(:creatives, [:user_id])
  end
end
