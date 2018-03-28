defmodule CodeFund.Repo.Migrations.CreateTemplates do
  use Ecto.Migration

  def change do
    create table(:templates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :slug, :string
      add :description, :text
      add :body, :text

      timestamps()
    end

    create unique_index(:templates, [:slug])
  end
end
