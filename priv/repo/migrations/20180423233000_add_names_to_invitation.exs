defmodule CodeFund.Repo.Migrations.AddNamesToInvitation do
  use Ecto.Migration

  def change do
    alter table(:invitations) do
      remove :name
      add :first_name, :string
      add :last_name, :string
    end
  end
end
