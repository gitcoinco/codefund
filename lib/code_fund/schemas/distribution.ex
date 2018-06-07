defmodule CodeFund.Schema.Distribution do
  use Ecto.Schema
  import Ecto.Changeset
  import Framework.Ecto.Changeset.Date

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
end
