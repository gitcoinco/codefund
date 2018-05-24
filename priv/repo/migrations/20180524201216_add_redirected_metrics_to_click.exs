defmodule CodeFund.Repo.Migrations.AddRedirectedMetricsToClick do
  use Ecto.Migration

  def change do
    alter table(:clicks) do
      add :redirected_at, :naive_datetime
      add :redirected_to_url, :string
    end
  end
end
