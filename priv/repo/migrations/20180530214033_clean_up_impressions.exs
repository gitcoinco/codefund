defmodule CodeFund.Repo.Migrations.CleanUpImpressions do
  use Ecto.Migration

  def change do
    alter table("impressions") do
      remove :is_bot
      remove :screen_height
      remove :screen_width
      remove :utm_campaign
      remove :utm_content
      remove :utm_medium
      remove :utm_source
      remove :utm_term
    end
  end
end
