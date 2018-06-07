defmodule CodeFund.Repo.Migrations.DropUserIdFromAudiences do
  use Ecto.Migration

  def change do
    alter table(:audiences) do
      remove :user_id
    end
  end
end
