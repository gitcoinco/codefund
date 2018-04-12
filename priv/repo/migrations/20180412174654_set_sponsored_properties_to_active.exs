defmodule CodeFund.Repo.Migrations.SetSponsoredPropertiesToActive do
  use Ecto.Migration

  def up do
    execute "update properties set status = 1 where sponsorship_id is not null;"
  end

  def down do
    execute "update properties set status = 0;"
  end
end
