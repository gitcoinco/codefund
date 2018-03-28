defmodule CodeFund.Repo.Migrations.CreateCoherenceInvitable do
  use Ecto.Migration
  def change do
    create table(:invitations, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string
      add :email, :string
      add :token, :string
      timestamps()
    end
    create unique_index(:invitations, [:email])
    create index(:invitations, [:token])

  end
end
