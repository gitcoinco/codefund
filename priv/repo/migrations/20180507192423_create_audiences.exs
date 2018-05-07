defmodule CodeFund.Repo.Migrations.CreateAudiences do
  use Ecto.Migration

  def change do
    create table(:audiences, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :programming_languages, {:array, :string}, default: "{}"

      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:audiences, [:user_id])
    create index(:audiences, [:programming_languages])
  end
end
