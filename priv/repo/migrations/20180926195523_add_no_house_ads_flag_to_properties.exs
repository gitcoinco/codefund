defmodule CodeFund.Repo.Migrations.AddNoHouseAdsFlagToProperties do
  use Ecto.Migration

  def change do
    alter table(:properties) do
      add :no_api_house_ads, :boolean, default: false, null: false
    end
  end
end
