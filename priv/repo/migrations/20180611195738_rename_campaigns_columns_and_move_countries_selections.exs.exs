defmodule CodeFund.Repo.Migrations.RenameCampaignColumnsAndMoveCountriesSelections do
  use Ecto.Migration

  def change do
    alter table(:audiences) do
      remove :excluded_countries
    end

    alter table(:campaigns) do
      add :included_countries, {:array, :string}, default: "{}"
      add :impression_count, :integer, default: 0, null: false
    end

    rename table(:campaigns), :bid_amount, to: :ecpm
  end
end
