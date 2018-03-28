defmodule CodeFund.Repo.Migrations.AddSponsorshipToProperties do
  use Ecto.Migration

  def change do
    alter table("properties") do
      add :sponsorship_id, references(:sponsorships, on_delete: :nothing, type: :binary_id)
    end

    create index(:properties, [:sponsorship_id])
  end
end
