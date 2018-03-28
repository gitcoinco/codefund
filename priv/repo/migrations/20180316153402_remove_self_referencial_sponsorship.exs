defmodule CodeFund.Repo.Migrations.RemoveSelfReferencialSponsorship do
  use Ecto.Migration

  def change do
    drop_if_exists index(:sponsorships, [:sponsorship_id])
    
    alter table("sponsorships") do
      remove :sponsorship_id
    end
  end
end
