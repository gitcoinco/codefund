defmodule CodeFund.Repo.Migrations.CreateDistributions do
  use Ecto.Migration

  def change do
    create table(:distributions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :amount, :decimal, precision: 10, scale: 2, null: false
      add :currency, :string, null: false
      add :click_range_start, :naive_datetime, null: false
      add :click_range_end, :naive_datetime, null: false

      timestamps()
    end

    alter table(:clicks) do
      add :distribution_id, references(:distributions, on_delete: :nothing, type: :binary_id)
    end
  end
end
