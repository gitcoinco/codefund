defmodule Mix.Tasks.AudienceTagToCampaign.Copy do
  use Mix.Task
  import Mix.Ecto
  import Ecto.Query
  @repo CodeFund.Repo

  @shortdoc "copies audience programming languages and topic categories to campaigns which use that audience"
  def run(_) do
    ensure_repo(@repo, [])
    ensure_migrations_path(@repo)
    {:ok, _pid, _apps} = ensure_started(@repo, [])

    for %CodeFund.Schema.Audience{
          id: audience_id,
          programming_languages: programming_languages,
          topic_categories: topic_categories
        } <- CodeFund.Audiences.list_audiences() do
      for campaign <- find_campaigns_by_audience_id(audience_id) do
        params = %{
          "included_programming_languages" => programming_languages,
          "included_topic_categories" => topic_categories
        }

        CodeFund.Schema.Campaign.changeset(campaign, params)
        |> CodeFund.Repo.update()
      end
    end
  end

  defp find_campaigns_by_audience_id(audience_id) do
    from(c in CodeFund.Schema.Campaign, where: c.audience_id == ^audience_id)
    |> CodeFund.Repo.all()
  end
end
