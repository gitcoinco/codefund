defmodule CodeFund.Repo.Migrations.AddExcludedAdvertisersToProperty do
  use Ecto.Migration

  def change do
    alter table(:properties) do
      add :excluded_advertisers, {:array, :string}, default: "{}"
    end
  end
end
