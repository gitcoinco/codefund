defmodule Mix.Tasks.ImpressionCountryUpdater.Update do
  use Mix.Task
  import Mix.Ecto
  require Logger

  @repo CodeFund.Repo

  @shortdoc "updates impressions with country data if possible"
  def run(_) do
    ensure_repo(@repo, [])
    ensure_migrations_path(@repo)
    {:ok, _pid, _apps} = ensure_started(@repo, [])
    Geolix.Supervisor.start_link()

    if Mix.env() != :test do
      for impression <- fetch_impressions() do
        ip =
          impression.ip
          |> String.split(".")
          |> Enum.map(
            &(Integer.parse(&1)
              |> elem(0))
          )
          |> List.to_tuple()

        try do
          {:ok, country} = Framework.Geolocation.find_by_ip(ip, :country)
          id = impression.id |> Ecto.UUID.cast!()

          impression
          |> Map.put(:id, id)
          |> CodeFund.Schema.Impression.changeset(%{country: country || nil})
          |> CodeFund.Repo.update()
        rescue
          _ ->
            Logger.info("couldn't update country")
        end
      end
    end
  end

  defp fetch_impressions do
    sql = "SELECT * FROM impressions WHERE country IS NULL;"

    res = Ecto.Adapters.SQL.query!(CodeFund.Repo, sql, [], timeout: :infinity)
    cols = Enum.map(res.columns, &String.to_atom(&1))

    Enum.map(res.rows, fn row ->
      struct(CodeFund.Schema.Impression, Enum.zip(cols, row))
    end)
  end
end
