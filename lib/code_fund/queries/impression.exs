defmodule CodeFund.Query.Impression do
  @moduledoc """
  Container for all queries on the `impressions` table.

  - Public methods should only return `Ecto.Query`.
  - Public methods should be composable... accepting an `Ecto.Query` as an argument.
  - Consumers are responsible for actually fetching data from the `Repo`.
  """

  use CodeFundWeb, :query
  @schema CodeFund.Schema.Impression

  @doc """
  Appends a count select to the passed query.

  ## Examples

    iex>CodeFund.Repo.to_sql :all, CodeFund.Query.Impression.count()
    {"SELECT count(i0.\"id\") FROM \"impressions\" AS i0", []}
  """
  def count(query \\ @schema) do
    from(record in query, select: count(record.id))
  end
end
