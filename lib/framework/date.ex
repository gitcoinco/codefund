defprotocol Framework.Date do
  @fallback_to_any true
  def parse(date)
end

defimpl Framework.Date, for: BitString do
  def parse(date_string) do
    Ecto.DateTime.cast!(date_string <> " 00:00:00")
    |> Ecto.DateTime.to_erl()
    |> NaiveDateTime.from_erl!()
  end
end

defimpl Framework.Date, for: Any do
  def parse(_date_string), do: ""
end
