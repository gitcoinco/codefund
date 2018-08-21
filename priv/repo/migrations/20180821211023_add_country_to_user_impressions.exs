defmodule CodeFund.Repo.Migrations.AddCountryToUserImpressions do
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
        impressions.country,
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
    create(index("user_impressions", [:country]))

    execute("""
    CREATE MATERIALIZED VIEW budgeted_campaigns AS
      WITH data AS (
        SELECT
          campaigns.id AS campaign_id,
          campaigns.user_id,
          campaigns.total_spend,
          campaigns.status AS status,
          campaigns.name AS campaign_name,
          campaigns.ecpm AS target_ecpm,
          campaigns.impression_count AS estimated_impressions,
          SUM(user_impressions.revenue_amount) AS revenue_amount,
          SUM(user_impressions.distribution_amount) AS distribution_amount,
          COUNT(user_impressions.id) AS total_impressions,
          users.company AS advertiser_company_name,
          audiences.id AS audience_id,
          audiences.name AS audience_name,
          creatives.id AS creative_id,
          creatives.name AS creative_name
        FROM campaigns
        JOIN user_impressions ON user_impressions.campaign_id = campaigns.id
        JOIN users ON campaigns.user_id = users.id
        JOIN audiences ON campaigns.audience_id = audiences.id
        JOIN creatives ON campaigns.creative_id = creatives.id
        GROUP BY campaigns.id, users.company, audiences.id, creatives.id, audiences.name, creatives.name
      )
      SELECT
        *,
        (total_spend - revenue_amount) AS balance,
        ((revenue_amount / total_impressions) * 1000) AS actual_ecpm
      FROM data;
  """)

  create(unique_index("budgeted_campaigns", [:campaign_id]))
  create(index("budgeted_campaigns", [:user_id]))
  create(index("budgeted_campaigns", [:campaign_name]))
  create(index("budgeted_campaigns", [:advertiser_company_name]))
  create(index("budgeted_campaigns", [:audience_id]))
  create(index("budgeted_campaigns", [:creative_id]))
  create(index("budgeted_campaigns", [:audience_name]))
  create(index("budgeted_campaigns", [:creative_name]))
  end
end
