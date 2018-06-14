defmodule Framework.Ecto.Changeset.Date do
  import Framework.Ecto.Date
  import Ecto.Changeset

  @spec cast_dates(Ecto.Changeset.t(), map, list) :: Ecto.Changeset.t()
  def cast_dates(changeset, params, [current_datefield_to_check | remaining_dates]) do
    with :error <- Map.get(params, to_string(current_datefield_to_check)) |> cast_date() do
      changeset
      |> add_error(current_datefield_to_check, "can't be blank", validation: :required)
      |> cast_dates(params, remaining_dates)
    else
      %NaiveDateTime{} ->
        cast_time =
          params
          |> Map.get(to_string(current_datefield_to_check))
          |> cast_date()

        changeset
        |> put_change(current_datefield_to_check, cast_time)
        |> cast_dates(params, remaining_dates)
    end
  end

  def cast_dates(changeset, _params, []), do: changeset

  defp cast_date(date_time_string) when is_binary(date_time_string) or is_nil(date_time_string),
    do: parse(date_time_string)

  defp cast_date(%NaiveDateTime{} = date_time), do: date_time
end
