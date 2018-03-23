defmodule CodeSponsorWeb.ViewHelpers do
  
  @doc ~S"""
  Converts a Decimal to a formatted currency amount

  ## Examples

      iex> CodeSponsorWeb.ViewHelpers.pretty_money(Decimal.new(1753.50), "USD")
      "$175,3.50"

  """
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

  def has_any_role?(conn, target_roles) do
    if Coherence.logged_in?(conn) do
      current_user = Coherence.current_user(conn)
      matches = Enum.filter(current_user.roles, fn(role) -> Enum.member?(target_roles, role) end)
      !Enum.empty?(matches)
    else
      false
    end
  end

  def full_name(%CodeSponsor.Schema.User{} = user) do
    "#{user.first_name} #{user.last_name}"
  end
end