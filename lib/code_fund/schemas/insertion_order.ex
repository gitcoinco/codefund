defmodule CodeFund.Schema.InsertionOrder do
  use Ecto.Schema
  import Ecto.Changeset
  import Framework.Ecto.Changeset.Date
  alias CodeFund.Schema.InsertionOrder

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "insertion_orders" do
    belongs_to(:user, CodeFund.Schema.User)
    belongs_to(:audience, CodeFund.Schema.Audience)

    field(:billing_cycle, :naive_datetime)
    field(:impression_count, :integer)

    timestamps()
  end

  @required [
    :impression_count,
    :billing_cycle,
    :audience_id,
    :user_id
  ]

  def required, do: @required

  @doc false
  def changeset(%InsertionOrder{} = insertion_order, params) do
    insertion_order
    |> cast(params, [:impression_count, :audience_id, :user_id])
    |> cast_dates(params, [:billing_cycle])
    |> validate_required(@required)
  end
end
