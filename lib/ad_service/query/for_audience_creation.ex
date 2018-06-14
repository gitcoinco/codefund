defmodule AdService.Query.ForAudienceCreation do
  import Ecto.Query

  def metrics([{:included_countries, included_countries} | filters]) do
    from(
      impression in CodeFund.Schema.Impression,
      where:
        impression.inserted_at >= ^beginning_of_last_month() and
          impression.inserted_at <= ^end_of_last_month(),
      where: impression.country in ^included_countries,
      join: property in assoc(impression, :property),
      select: %{
        "impression_count" => count(impression.id),
        "unique_user_count" => count(impression.ip, :distinct),
        "property_count" => count(property.id, :distinct)
      }
    )
    |> AdService.Query.Shared.build_where_clauses_by_property_filters(filters)
    |> CodeFund.Repo.one()
  end

  defp beginning_of_last_month() do
    Timex.shift(Timex.now(), months: -1) |> Timex.beginning_of_month()
  end

  defp end_of_last_month() do
    Timex.shift(Timex.now(), months: -1) |> Timex.end_of_month()
  end
end
