defmodule AdService.ImpressionErrors do
  @errors [
    property_inactive: 0,
    impression_count_exceeded: 1,
    no_possible_ads: 2
  ]

  @spec fetch_code(atom) :: integer
  def fetch_code(error_atom), do: @errors |> Keyword.fetch!(error_atom)
end
