defmodule CodeFund.Repo.Migrations.AddUserIdToSponsorships do
  use Ecto.Migration

  def change do
    alter table("sponsorships") do
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
    end

    create index(:sponsorships, [:user_id])
  end
end
