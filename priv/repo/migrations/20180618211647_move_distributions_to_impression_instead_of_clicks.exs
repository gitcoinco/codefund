defmodule CodeFund.Repo.Migrations.MoveDistributionsToImpressionInsteadOfClicks do
  use Ecto.Migration

  def change do
    rename table(:distributions), :click_range_start, to: :range_start
    rename table(:distributions), :click_range_end, to: :range_end

    alter table(:impressions) do
      add :distribution_id, references(:distributions, on_delete: :nothing, type: :binary_id)
    end
  end
end
