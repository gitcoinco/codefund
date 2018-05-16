defmodule CodeFund.Repo.Migrations.AddDateIndexesToClicksAndImpressions do
  use Ecto.Migration

  def up do
    execute "CREATE INDEX IF NOT EXISTS index_impressions_on_inserted_at_date ON impressions USING btree (((inserted_at)::date));"
    execute "CREATE INDEX IF NOT EXISTS index_clicks_on_inserted_at_date ON clicks USING btree (((inserted_at)::date));"
  end

  def down do
    execute "DROP INDEX index_clicks_on_inserted_at_date;"
    execute "DROP INDEX index_impressions_on_inserted_at_date;"
  end
end
