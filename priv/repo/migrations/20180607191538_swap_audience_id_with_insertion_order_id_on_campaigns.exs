defmodule CodeFund.Repo.Migrations.SwapAudienceIdWithInsertionOrderIdOnCampaigns do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      remove :audience_id
      add :insertion_order_id, references(:insertion_orders, on_delete: :nothing, type: :binary_id)
    end
  end
end
