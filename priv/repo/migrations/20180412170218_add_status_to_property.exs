defmodule CodeFund.Repo.Migrations.AddStatusToProperty do
  use Ecto.Migration

  def change do
    alter table(:properties) do
      add :status, :integer, default: 0
    end
  end
end
