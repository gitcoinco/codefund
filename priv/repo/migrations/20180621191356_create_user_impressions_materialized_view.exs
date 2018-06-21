defmodule CodeFund.Repo.Migrations.CreateUserImpressionsMaterializedView do
  use Ecto.Migration

  def change do
    execute("""
      CREATE MATERIALIZED VIEW user_impressions AS
        SELECT campaigns.user_id AS campaign_user_id,
        impressions.id,
        impressions.campaign_id,
        impressions.revenue_amount,
        impressions.distribution_amount,
        impressions.inserted_at,
        properties.name AS property_name,
        properties.user_id AS property_user_id,
        audiences.name AS audience_name
        FROM impressions
        JOIN campaigns ON impressions.campaign_id = campaigns.id
        JOIN properties ON impressions.property_id = properties.id
        JOIN audiences ON campaigns.audience_id = audiences.id;
    """)

    create unique_index("user_impressions", [:id])

    create index("user_impressions", [:campaign_user_id])
    create index("user_impressions", [:property_user_id])
    create index("user_impressions", [:revenue_amount])
    create index("user_impressions", [:distribution_amount])
    create index("user_impressions", [:property_name])
    create index("user_impressions", [:audience_name])
    create index("user_impressions", [:inserted_at])
  end
end
