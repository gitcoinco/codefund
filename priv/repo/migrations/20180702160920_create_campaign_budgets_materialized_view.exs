defmodule CodeFund.Repo.Migrations.CreateCampaignBudgetsMaterializedView do
  use Ecto.Migration

  def up do
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

  def down do
    execute("DROP MATERIALIZED VIEW budgeted_campaigns CASCADE")
  end
end
