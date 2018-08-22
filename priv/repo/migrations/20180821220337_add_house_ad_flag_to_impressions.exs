defmodule CodeFund.Repo.Migrations.AddHouseAdFlagToImpressions do
  use Ecto.Migration

  def change do
    alter table(:impressions) do
      add(:house_ad, :boolean, default: false)
    end
  end
end
