defmodule CodeSponsor.Repo.Migrations.CreateThemes do
  use Ecto.Migration

  def change do
    create table(:themes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :slug, :string
      add :description, :text
      add :body, :text

      timestamps()
    end

    create unique_index(:themes, [:slug])
  end
end
