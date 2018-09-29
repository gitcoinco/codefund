defmodule CodeFund.UserImpressions do
  alias CodeFund.Schema.UserImpression
  use CodeFundWeb, :query

  def count_for_last_thirty_days() do
    from(user_impression in UserImpression,
      where: fragment("?::date between ?::date and ?::date", user_impression.inserted_at, ^start_date(), ^now_as_date()),
      select: count(user_impression.id)
    ) |> CodeFund.Repo.one
  end

  def distributions_for_last_thirty_days do
    from(user_impression in UserImpression,
      where: fragment("?::date between ?::date and ?::date", user_impression.inserted_at, ^start_date(), ^now_as_date()),
      select: sum(user_impression.distribution_amount)
    ) |> CodeFund.Repo.one
  end

  def ctr_for_last_thirty_days do
    from(user_impression in UserImpression,
      where: fragment("?::date between ?::date and ?::date", user_impression.inserted_at, ^start_date(), ^now_as_date()),
      where: not(is_nil(user_impression.redirected_at)),
      select: count(user_impression.id)
    ) |> CodeFund.Repo.one
  end

  defp start_date() do
    Timex.now |> Timex.to_date() |> Timex.shift(days: -30) |> Timex.to_date
  end

  defp now_as_date() do
    Timex.now |> Timex.to_date()
  end
end
