defmodule CodeFund.Repo.Migrations.UserImpressionsViewV3 do
  use Ecto.Migration

  def change do
    execute("DROP MATERIALIZED VIEW user_impressions CASCADE")

    execute("""
      CREATE MATERIALIZED VIEW user_impressions AS
        SELECT campaigns.user_id AS campaign_user_id,
        impressions.id,
        impressions.campaign_id,
        impressions.revenue_amount,
        impressions.distribution_amount,
        impressions.inserted_at,
        impressions.redirected_at,
        properties.name AS property_name,
        properties.user_id AS property_user_id,
        audiences.name AS audience_name,
        campaigns.name AS campaign_name,
        users.company AS advertiser_company_name
        FROM impressions
        JOIN campaigns ON impressions.campaign_id = campaigns.id
        JOIN properties ON impressions.property_id = properties.id
        JOIN audiences ON campaigns.audience_id = audiences.id
        JOIN users ON campaigns.user_id = users.id;
    """)

    create(unique_index("user_impressions", [:id]))

    create(index("user_impressions", [:campaign_user_id]))
    create(index("user_impressions", [:property_user_id]))
    create(index("user_impressions", [:revenue_amount]))
    create(index("user_impressions", [:distribution_amount]))
    create(index("user_impressions", [:property_name]))
    create(index("user_impressions", [:audience_name]))
    create(index("user_impressions", [:campaign_name]))
    create(index("user_impressions", [:advertiser_company_name]))
    create(index("user_impressions", [:inserted_at]))
    create(index("user_impressions", [:redirected_at]))
  end
end
