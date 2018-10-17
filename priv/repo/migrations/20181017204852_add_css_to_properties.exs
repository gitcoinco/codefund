defmodule CodeFund.Repo.Migrations.AddCssToProperties do
  use Ecto.Migration

  def change do
    alter table(:properties) do
      add :css_override, :text
    end
  end
end
