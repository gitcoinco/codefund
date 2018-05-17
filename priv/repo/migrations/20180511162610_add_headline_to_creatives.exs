defmodule CodeFund.Repo.Migrations.AddHeadlineToCreatives do
  use Ecto.Migration

  def change do
    alter table(:creatives) do
      add :headline, :string
    end
  end
end
