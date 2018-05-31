defmodule CodeFund.Repo.Migrations.AddRedirectionAttrsToImpression do
  use Ecto.Migration

  def change do
    alter table(:impressions) do
      add :redirected_at, :naive_datetime
      add :redirected_to_url, :string
    end
  end
end
