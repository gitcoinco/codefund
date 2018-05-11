defmodule CodeFund.Repo.Migrations.AddTitleToCreatives do
  use Ecto.Migration

  def change do
    alter table(:creatives) do
      add :title, :string
    end
  end
end
