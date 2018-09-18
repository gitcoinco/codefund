defmodule CodeFund.Repo.Migrations.AddApiAccessAndApiKeyToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :api_access, :boolean, default: false, null: false
      add :api_key, :string
    end
  end
end
