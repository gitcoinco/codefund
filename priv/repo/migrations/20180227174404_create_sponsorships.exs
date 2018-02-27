defmodule CodeSponsor.Repo.Migrations.CreateSponsorships do
  use Ecto.Migration

  def change do
    create table(:sponsorships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :bid_amount_cents, :integer, null: false, default: 0
      add :property_id, references(:properties, on_delete: :nothing, type: :binary_id)
      add :campaign_id, references(:campaigns, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:sponsorships, [:property_id])
    create index(:sponsorships, [:campaign_id])
  end
end
