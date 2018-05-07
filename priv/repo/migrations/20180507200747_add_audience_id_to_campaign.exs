defmodule CodeFund.Repo.Migrations.AddAudienceIdToCampaign do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :audience_id, references(:audiences, on_delete: :nothing, type: :binary_id)
    end
  end
end
