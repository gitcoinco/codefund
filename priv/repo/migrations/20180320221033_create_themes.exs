defmodule CodeFund.Repo.Migrations.CreateThemes do
  use Ecto.Migration

  def change do
    create table(:themes, primary_key: false) do
      add :template_id, references(:templates, on_delete: :nothing, type: :binary_id)
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :slug, :string
      add :description, :text
      add :body, :text

      timestamps()
    end

    create unique_index(:themes, [:template_id, :slug])
    create index(:themes, [:template_id])
  end
end
