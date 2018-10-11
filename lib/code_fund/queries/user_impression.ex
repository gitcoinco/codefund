defmodule CodeFund.Query.UserImpression do
  @moduledoc """
  Container for all queries on the `user_impressions` table.

  Public methods in this module should only return `Ecto.Query`.
  Consumers are responsible for actually fetching data from the `Repo`.
  """

  use CodeFundWeb, :query
  @schema CodeFund.Schema.UserImpression

  def paid(query \\ @schema) do
    from(user_impression in query,
      where: user_impression.house_ad == false
    )
  end

  def last_thirty_days(query \\ @schema) do
    from(user_impression in query,
      where:
        fragment(
          "?::date between ?::date and ?::date",
          user_impression.inserted_at,
          ^thirty_days_ago_as_date(),
          ^now_as_date()
        )
    )
  end

  def impression_count_for_last_thirty_days(query \\ @schema) do
    query = query |> last_thirty_days()

    from(user_impression in query,
      select: count(user_impression.id)
    )
  end

  def paid_impression_count_for_last_thirty_days(query \\ @schema) do
    paid(query) |> impression_count_for_last_thirty_days()
  end

  def click_count_for_last_thirty_days(query \\ @schema) do
    query = query |> last_thirty_days()

    from(user_impression in query,
      where: not is_nil(user_impression.redirected_at),
      select: count(user_impression.id)
    )
  end

  def paid_click_count_for_last_thirty_days(query \\ @schema) do
    paid(query) |> click_count_for_last_thirty_days()
  end

  def distribution_amount_for_last_thirty_days(query \\ @schema) do
    query = query |> paid() |> last_thirty_days()

    from(user_impression in query,
      select: sum(user_impression.distribution_amount)
    )
  end

  defp thirty_days_ago_as_date() do
    Timex.now() |> Timex.to_date() |> Timex.shift(days: -30) |> Timex.to_date()
  end

  defp now_as_date() do
    Timex.now() |> Timex.to_date()
  end
end
