defmodule CodeFund.Repo.Migrations.AddImpressionIdToClicks do
  use Ecto.Migration

  def change do
    alter table(:clicks) do
      add :impression_id, references(:impressions, on_delete: :nothing, type: :binary_id)
    end
  end
end
