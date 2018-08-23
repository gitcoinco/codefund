defmodule CodeFund.Repo.Migrations.RedefineIndicesOnMaterializedViews do
  use Ecto.Migration
  @disable_ddl_transaction true

  def change do
    create(unique_index("user_impressions", [:id], concurrently: true))

    create(index("user_impressions", [:campaign_user_id], concurrently: true))
    create(index("user_impressions", [:property_user_id], concurrently: true))
    create(index("user_impressions", [:revenue_amount], concurrently: true))
    create(index("user_impressions", [:distribution_amount], concurrently: true))
    create(index("user_impressions", [:property_name], concurrently: true))
    create(index("user_impressions", [:audience_name], concurrently: true))
    create(index("user_impressions", [:campaign_name], concurrently: true))
    create(index("user_impressions", [:advertiser_company_name], concurrently: true))
    create(index("user_impressions", [:inserted_at], concurrently: true))
    create(index("user_impressions", [:redirected_at], concurrently: true))
    create(index("user_impressions", [:country], concurrently: true))
    create(index("user_impressions", [:house_ad], concurrently: true))

    create(unique_index("budgeted_campaigns", [:campaign_id], concurrently: true))
    create(index("budgeted_campaigns", [:user_id], concurrently: true))
    create(index("budgeted_campaigns", [:campaign_name], concurrently: true))
    create(index("budgeted_campaigns", [:advertiser_company_name], concurrently: true))
    create(index("budgeted_campaigns", [:audience_id], concurrently: true))
    create(index("budgeted_campaigns", [:creative_id], concurrently: true))
    create(index("budgeted_campaigns", [:audience_name], concurrently: true))
    create(index("budgeted_campaigns", [:creative_name], concurrently: true))
  end
end
