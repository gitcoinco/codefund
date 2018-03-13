defmodule CodeSponsor.Repo.Migrations.RemoveSelfReferenceInSponsorships do
  use Ecto.Migration

  def change do
    alter table("sponsorships") do
      remove :sponsorship_id
    end
  end
end
