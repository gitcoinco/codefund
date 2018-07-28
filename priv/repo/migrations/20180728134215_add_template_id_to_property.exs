defmodule CodeFund.Repo.Migrations.AddTemplateIdToProperty do
  use Ecto.Migration

  def change do
    alter table(:properties) do
      add(:template_id, references(:templates, on_delete: :nothing, type: :binary_id))
    end
    create(index(:properties, [:template_id]))
  end
end
