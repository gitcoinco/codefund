defmodule CodeFund.Repo.Migrations.ConvertUserImpressionsInsertedAtToDate do
  use Ecto.Migration
  @disable_ddl_transaction true

  def up do
    drop_if_exists index("user_impressions", [:inserted_at])
    drop_if_exists index("user_impressions", [:redirected_at])
    execute("CREATE INDEX CONCURRENTLY user_impressions_inserted_at_index ON user_impressions ( date(inserted_at) )")
    execute("CREATE INDEX CONCURRENTLY user_impressions_redirected_at_index ON user_impressions ( date(redirected_at) )")
  end

  def down do
    drop_if_exists index("user_impressions", [:inserted_at])
    drop_if_exists index("user_impressions", [:redirected_at])
    create(index("user_impressions", [:inserted_at], concurrently: true))
    create(index("user_impressions", [:redirected_at], concurrently: true))
  end
end
