defmodule CodeFund.Repo.Migrations.AddErrorCodeToImpressions do
  use Ecto.Migration

  def change do
    alter table(:impressions) do
      add(:error_code, :integer)
    end
  end
end
