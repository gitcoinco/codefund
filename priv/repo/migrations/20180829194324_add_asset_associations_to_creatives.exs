defmodule CodeFund.Repo.Migrations.AddAssetAssociationsToCreatives do
  use Ecto.Migration

  def change do
    alter table(:creatives) do
      add :small_image_asset_id, references(:assets, on_delete: :nothing, type: :binary_id)
      add :large_image_asset_id, references(:assets, on_delete: :nothing, type: :binary_id)
    end
  end
end
