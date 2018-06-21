defmodule Mix.Tasks.UserImpressionsView.Refresh do
  use Mix.Task
  import Mix.Ecto
  @repo CodeFund.Repo

  @shortdoc "refreshes the user_impressions materialized view"
  def run(_) do
    ensure_repo(@repo, [])
    ensure_migrations_path(@repo)
    {:ok, _pid, _apps} = ensure_started(@repo, [])

    sql = "REFRESH MATERIALIZED VIEW CONCURRENTLY user_impressions;"

    Ecto.Adapters.SQL.query!(@repo, sql, [], timeout: :infinity)
  end
end
