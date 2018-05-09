defmodule CodeFund.Repo.Migrations.AddNullFalsesToProperties do
  use Ecto.Migration

  def change do
    execute "UPDATE properties set language = '' where language is null;"
    alter table(:properties) do
      modify :language, :string, null: false
      modify :programming_languages, {:array, :string}, default: "{}", null: false
      modify :topic_categories, {:array, :string}, default: "{}", null: false
    end
  end
end
