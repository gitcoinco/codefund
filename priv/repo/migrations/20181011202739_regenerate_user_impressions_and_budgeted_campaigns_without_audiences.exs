defmodule CodeFund.Repo.Migrations.RegenerateUserImpressionsAndBudgetedCampaignsWithoutAudiences do
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
        impressions.house_ad,
        properties.name AS property_name,
        properties.user_id AS property_user_id,
        campaigns.name AS campaign_name,
        users.company AS advertiser_company_name
        FROM impressions
        JOIN campaigns ON impressions.campaign_id = campaigns.id
        JOIN properties ON impressions.property_id = properties.id
        JOIN users ON campaigns.user_id = users.id;
    """)

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
          creatives.id AS creative_id,
          creatives.name AS creative_name
        FROM campaigns
        JOIN user_impressions ON user_impressions.campaign_id = campaigns.id
        JOIN users ON campaigns.user_id = users.id
        JOIN creatives ON campaigns.creative_id = creatives.id
        GROUP BY campaigns.id, users.company, creatives.id, creatives.name
      )
      SELECT
        *,
        (total_spend - revenue_amount) AS balance,
        ((revenue_amount / total_impressions) * 1000) AS actual_ecpm
      FROM data;
  """)
  end
end
