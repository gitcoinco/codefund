defmodule CodeFund.Repo.Migrations.AddTopicCategoriesToAudiences do
  use Ecto.Migration

  def change do
    alter table(:audiences) do
      add :topic_categories, {:array, :string}, default: "{}"
    end
  end
end
