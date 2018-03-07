defmodule CodeSponsor.Sigils do
  @doc ~S"""
  This adds Decimal.new as a sigil

  ##  Examples
  
      iex> ~n(3.50)
      #Decimal<3.50>

  """
  def sigil_n(number, []), do: Decimal.new(number)
end