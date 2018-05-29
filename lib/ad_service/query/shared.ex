defmodule AdService.Query.Shared do
  import Ecto.Query

  @spec build_where_clauses_by_property_filters(Ecto.Query.t(), list) :: Ecto.Query.t()
  def build_where_clauses_by_property_filters(query, []), do: query

  def build_where_clauses_by_property_filters(query, [{field_name, value} | tail]) do
    query
    |> where_clause(field_name, value)
    |> build_where_clauses_by_property_filters(tail)
  end

  @spec where_clause(Ecto.Query.t(), atom, list | binary) :: Ecto.Query.t()
  defp where_clause(query, :client_country, value) do
    query
    |> where(
      [..., audience],
      ^value not in audience.excluded_countries
    )
  end

  defp where_clause(query, field_name, value) when is_list(value) and length(value) > 0 do
    query
    |> where(
      [..., audience_or_property],
      fragment("? && ?::varchar[]", field(audience_or_property, ^field_name), ^value)
    )
  end

  defp where_clause(query, field_name, value) when is_binary(value) do
    query
    |> where([..., audience_or_property], field(audience_or_property, ^field_name) == ^value)
  end

  defp where_clause(query, _field_name, _value), do: query
end
