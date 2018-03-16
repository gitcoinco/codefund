defmodule CodeSponsor.Repo.Migrations.AddFraudCheckRedirectedAtToClicks do
  use Ecto.Migration

  def change do
    alter table("clicks") do
      add :fraud_check_redirected_at, :naive_datetime
    end
  end
end
