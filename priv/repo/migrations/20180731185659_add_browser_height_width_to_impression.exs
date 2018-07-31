defmodule CodeFund.Repo.Migrations.AddBrowserHeightWidthToImpression do
  use Ecto.Migration

  def change do
    alter table(:impressions) do
      add :browser_height, :integer
      add :browser_width, :integer
    end
  end
end
