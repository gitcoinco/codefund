defmodule CodeFund.Repo.Migrations.AddTagsToCampaign do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :included_programming_languages, {:array, :string}, default: "{}"
      add :included_topic_categories, {:array, :string}, default: "{}"
      add :excluded_programming_languages, {:array, :string}, default: "{}"
      add :excluded_topic_categories, {:array, :string}, default: "{}"
    end
  end
end
