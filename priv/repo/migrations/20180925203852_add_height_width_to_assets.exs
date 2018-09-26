defmodule CodeFund.Repo.Migrations.AddHeightWidthToAssets do
  use Ecto.Migration

  def change do
    alter table(:assets) do
      add :height, :integer
      add :width, :integer
    end
  end
end
