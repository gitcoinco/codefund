defmodule Framework.Ecto.Changeset.Date do
  import Framework.Ecto.Date
  import Ecto.Changeset

  @spec cast_dates(Ecto.Changeset.t(), map, list) :: Ecto.Changeset.t()
  def cast_dates(changeset, params, [current_datefield_to_check | remaining_dates]) do
    with date_time_string <- Map.get(params, to_string(current_datefield_to_check)),
         %NaiveDateTime{} = cast_time <- parse(date_time_string) do
      changeset
      |> put_change(current_datefield_to_check, cast_time)
      |> cast_dates(params, remaining_dates)
    else
      :error ->
        changeset
        |> add_error(current_datefield_to_check, "can't be blank", validation: :required)
        |> cast_dates(params, remaining_dates)
    end
  end

  def cast_dates(changeset, _params, []), do: changeset
end
