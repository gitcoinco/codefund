defmodule CodeFund.Repo.Migrations.AddWideImageToCreatives do
  use Ecto.Migration

  def change do
    alter table(:creatives) do
      add :wide_image_asset_id, references(:assets, on_delete: :nothing, type: :binary_id)
    end
  end
end
