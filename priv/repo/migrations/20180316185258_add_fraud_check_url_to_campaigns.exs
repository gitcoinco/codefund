defmodule CodeFund.Repo.Migrations.AddFraudCheckUrlToCampaigns do
  use Ecto.Migration

  def change do
    alter table("campaigns") do
      add :fraud_check_url, :text
    end
  end
end
