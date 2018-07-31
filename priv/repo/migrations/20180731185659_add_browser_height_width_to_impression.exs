defmodule CodeFund.Repo.Migrations.AddBrowserHeightWidthToImpression do
  use Ecto.Migration

  def change do
    alter table(:impressions) do
      add :browser_height, :string
      add :browser_width, :string
    end
  end
end
