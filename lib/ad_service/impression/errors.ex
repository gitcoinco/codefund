defmodule AdService.Impression.Errors do
  @error_codes [
    nil: nil,
    property_inactive: 0,
    impression_count_exceeded: 1,
    no_possible_ads: 2
  ]

  @spec fetch_code(atom) :: integer
  def fetch_code(error_atom), do: @error_codes |> Keyword.fetch!(error_atom)

  @spec fetch_human_readable_message(atom) :: String.t()
  def fetch_human_readable_message(:property_inactive) do
    fetch_human_readable_message(:default) <> " - code: #{fetch_code(:property_inactive)}"
  end

  def fetch_human_readable_message(:default) do
    "This property is not currently active"
  end

  def fetch_human_readable_message(reason_atom) do
    "CodeFund does not have an advertiser for you at this time - code: #{
      AdService.Impression.Errors.fetch_code(reason_atom)
    }"
  end
end
