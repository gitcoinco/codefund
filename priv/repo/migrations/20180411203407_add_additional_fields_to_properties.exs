defmodule CodeFund.Repo.Migrations.AddAdditionalFieldsToProperties do
  use Ecto.Migration

  def change do
    alter table("properties") do
      add :estimated_monthly_page_views, :integer
      add :estimated_monthly_visitors, :integer
      add :alexa_site_rank, :integer
      add :language, :string
      add :programming_languages, {:array, :string}
      add :topic_categories, {:array, :string}
      add :screenshot_url, :text
    end
  end
end
