defmodule Framework.Module do
  @spec pretty(String.t(), atom, atom) :: String.t()
  def pretty(module, :upcase, :singular),
    do: module |> String.capitalize() |> Inflex.singularize()

  def pretty(module, :upcase, :plural), do: module |> String.capitalize() |> Inflex.pluralize()

  def pretty(module, :downcase, :singular),
    do: "#{module |> String.downcase() |> Inflex.singularize()}"

  def pretty(module, :downcase, :plural),
    do: pretty(module, :downcase, :singular) |> Inflex.pluralize()

  @spec module_name(String.t(), atom) :: atom
  def module_name(module, :context),
    do: Module.concat([CodeFund, pretty(module, :upcase, :plural)])

  def module_name(module, :struct_name),
    do: Module.concat([CodeFund, Schema, pretty(module, :upcase, :singular)])

  def module_name(module, :struct), do: module |> module_name(:struct_name) |> struct()

  def fully_qualified(conn) do
    conn.private.controller_config.nested
    |> Enum.concat([conn.private.controller_config.schema])
    |> Module.concat()
  end
end
