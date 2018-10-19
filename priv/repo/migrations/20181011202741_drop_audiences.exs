defmodule CodeFund.Repo.Migrations.DropAudiences do
  use Ecto.Migration

  def up do
    alter table(:campaigns) do
      remove :audience_id
    end
    alter table(:properties) do
      remove :audience_id
    end
    drop table(:audiences)
  end
end
