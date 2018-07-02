defmodule Mix.Tasks.BudgetedCampaignsView.Refresh do
  use Mix.Task
  import Mix.Ecto
  @repo CodeFund.Repo

  @shortdoc "refreshes the budgeted_campaigns materialized view"
  def run(_) do
    ensure_repo(@repo, [])
    ensure_migrations_path(@repo)
    {:ok, _pid, _apps} = ensure_started(@repo, [])

    sql = "REFRESH MATERIALIZED VIEW CONCURRENTLY budgeted_campaigns;"

    Ecto.Adapters.SQL.query!(@repo, sql, [], timeout: :infinity)
  end
end
