defmodule CodeFund.Query.UserImpression do
  @moduledoc """
  Container for all queries on the `user_impressions` table.

  - Public methods should only return `Ecto.Query`.
  - Public methods should be composable... accepting an `Ecto.Query` as an argument.
  - Consumers are responsible for actually fetching data from the `Repo`.
  """

  @schema CodeFund.Schema.UserImpression
  use CodeFundWeb, :query

  def count(query \\ @schema) do
    from(record in query, select: count(record.id))
  end

  def paid(query \\ @schema) do
    from(record in query,
      where: record.house_ad == false
    )
  end

  def last_thirty_days(query \\ @schema) do
    from(record in query,
      where:
        fragment(
          "?::date between ?::date and ?::date",
          record.inserted_at,
          ^thirty_days_ago_as_date(),
          ^now_as_date()
        )
    )
  end

  def impression_count_for_last_thirty_days(query \\ @schema) do
    query = query |> last_thirty_days()

    from(record in query,
      select: count(record.id)
    )
  end

  def paid_impression_count_for_last_thirty_days(query \\ @schema) do
    query |> paid() |> impression_count_for_last_thirty_days()
  end

  def click_count_for_last_thirty_days(query \\ @schema) do
    query = query |> last_thirty_days()

    from(record in query,
      where: not is_nil(record.redirected_at),
      select: count(record.id)
    )
  end

  def paid_click_count_for_last_thirty_days(query \\ @schema) do
    query |> paid() |> click_count_for_last_thirty_days()
  end

  def distribution_amount_for_last_thirty_days(query \\ @schema) do
    query = query |> paid() |> last_thirty_days()

    from(record in query,
      select: sum(record.distribution_amount)
    )
  end

  defp thirty_days_ago_as_date() do
    Timex.now() |> Timex.to_date() |> Timex.shift(days: -30) |> Timex.to_date()
  end

  defp now_as_date() do
    Timex.now() |> Timex.to_date()
  end
end
