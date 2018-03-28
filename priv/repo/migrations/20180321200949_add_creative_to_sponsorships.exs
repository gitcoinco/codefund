defmodule CodeFund.Repo.Migrations.AddCreativeToSponsorships do
  use Ecto.Migration

  def change do
    alter table("sponsorships") do
      add :creative_id, references(:creatives, on_delete: :nothing, type: :binary_id)
    end

    create index(:sponsorships, [:creative_id])
  end
end
