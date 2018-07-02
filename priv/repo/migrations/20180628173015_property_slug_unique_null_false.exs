defmodule CodeFund.Repo.Migrations.PropertySlugUniqueNullFalse do
  use Ecto.Migration

  def change do
    Mix.Tasks.PropertySlug.Generate.run(nil)
    create unique_index(:properties, :slug)
    alter table(:properties) do
      modify(:slug, :string, null: false)
    end
  end
end
