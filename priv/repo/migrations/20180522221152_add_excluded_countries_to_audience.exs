defmodule CodeFund.Repo.Migrations.AddExcludedCountriesToAudience do
  use Ecto.Migration

  def change do
    alter table(:audiences) do
      add :excluded_countries, {:array, :string}, default: "{}"
    end
  end
end
