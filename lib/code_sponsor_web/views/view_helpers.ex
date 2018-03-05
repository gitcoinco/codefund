defmodule CodeSponsorWeb.ViewHelpers do
  def pretty_money(amount, currency \\ "USD") do
    {:ok, ret} = Money.to_string Money.new(amount, currency), currency: currency
    String.replace(ret, "US", "")
  end

  def campaign_status(status) do
    options = ["Pending": 1, "Active": 2, "Archived": 3]
    options
    |> Enum.find(fn {_key, val} -> val == status end)
    |> elem(0)
  end
end