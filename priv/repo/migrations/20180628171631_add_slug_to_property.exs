defmodule CodeFund.Repo.Migrations.AddSlugToProperty do
  use Ecto.Migration

  def change do
    alter table(:properties) do
      add :slug, :string
    end
  end
end
