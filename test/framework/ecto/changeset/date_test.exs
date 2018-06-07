defmodule StubDateSchema do
  use Ecto.Schema
  import Ecto.Changeset
  import Framework.Ecto.Changeset.Date

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "stubs" do
    field(:date, :naive_datetime)
    field(:another_date, :naive_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = stub, params) do
    stub
    |> cast(params, [])
    |> cast_dates(params, [:date, :another_date])
  end
end

defmodule Framework.Ecto.Changeset.DateTest do
  use ExUnit.Case

  describe "cast_dates/3" do
    test "it casts a set of date strings to naivedatetimes" do
      changeset =
        %StubDateSchema{}
        |> StubDateSchema.changeset(%{"date" => "2018-01-02", "another_date" => "2018-10-20"})

      assert changeset.changes == %{
               another_date: ~N[2018-10-20 00:00:00],
               date: ~N[2018-01-02 00:00:00]
             }

      assert changeset.valid?
    end

    test "it returns an error if the date string is invalid" do
      changeset =
        %StubDateSchema{}
        |> StubDateSchema.changeset(%{"date" => "", "another_date" => "2018-10-20"})

      assert changeset.changes == %{
               another_date: ~N[2018-10-20 00:00:00]
             }

      assert changeset.errors == [date: {"can't be blank", [validation: :required]}]
      refute changeset.valid?
    end
  end
end
