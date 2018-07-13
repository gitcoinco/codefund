defmodule CodeFund.Repo.Migrations.AddAudienceToProperties do
  use Ecto.Migration

  def change do
    alter table(:properties) do
      add(:audience_id, references(:audiences, on_delete: :nothing, type: :binary_id))
    end
  end
end
