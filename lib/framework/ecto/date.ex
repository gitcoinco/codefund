defprotocol Framework.Ecto.Date do
  @fallback_to_any true
  @spec parse(String.t()) :: NaiveDateTime.t() | :error
  def parse(date)
end

defimpl Framework.Ecto.Date, for: BitString do
  def parse(date_string) do
    with {:ok, date_time} <- Ecto.DateTime.cast(date_string <> " 00:00:00") do
      date_time
      |> Ecto.DateTime.to_erl()
      |> NaiveDateTime.from_erl!()
    else
      :error -> :error
    end
  end
end

defimpl Framework.Ecto.Date, for: Any do
  def parse(_date_string), do: :error
end
