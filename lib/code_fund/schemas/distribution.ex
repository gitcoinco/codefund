defmodule CodeFund.Schema.Distribution do
  use Ecto.Schema
  import Ecto.Changeset
  import Framework.Date

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required ~w(amount currency click_range_start click_range_end)a

  schema "distributions" do
    has_many(:clicks, CodeFund.Schema.Click)
    field(:amount, :decimal)
    field(:currency, :string)
    field(:click_range_start, :naive_datetime)
    field(:click_range_end, :naive_datetime)

    timestamps()
  end

  def required(), do: @required

  @doc false
  def changeset(%__MODULE__{} = distribution, params) do
    distribution
    |> cast(params, [:amount, :currency])
    |> cast_dates(params, [:click_range_start, :click_range_end])
    |> validate_required(required())
  end

  def cast_dates(changeset, params, [current_datefield_to_check | remaining_dates]) do
    with date_time_string <- Map.get(params, to_string(current_datefield_to_check)),
         %NaiveDateTime{} = cast_time <- parse(date_time_string) do
      changeset
      |> put_change(current_datefield_to_check, cast_time)
      |> cast_dates(params, remaining_dates)
    else
      _an_error_case ->
        changeset
        |> add_error(current_datefield_to_check, "can't be blank", validation: :required)
        |> cast_dates(params, remaining_dates)
    end
  end

  def cast_dates(changeset, _params, []), do: changeset
end
