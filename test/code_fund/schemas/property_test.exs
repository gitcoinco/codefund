defmodule CodeFund.Schema.PropertyTest do
  use CodeFund.DataCase
  alias CodeFund.Schema.Property
  import CodeFund.Factory

  describe "properties" do
    setup do
      valid_attrs = build(:property) |> Map.from_struct()
      {:ok, %{valid_attrs: valid_attrs}}
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      assert Property.changeset(%Property{}, valid_attrs).valid?
    end

    test "changeset with missing user", %{valid_attrs: valid_attrs} do
      invalid_attrs = valid_attrs |> Map.delete(:user)
      changeset = Property.changeset(%Property{}, invalid_attrs)

      refute changeset.valid?
      assert changeset.errors == [user_id: {"can't be blank", [validation: :required]}]
    end

    test "changeset with missing name", %{valid_attrs: valid_attrs} do
      invalid_attrs = valid_attrs |> Map.delete(:name)
      changeset = Property.changeset(%Property{}, invalid_attrs)

      refute changeset.valid?
      assert changeset.errors == [name: {"can't be blank", [validation: :required]}]
    end

    test "changeset with missing url", %{valid_attrs: valid_attrs} do
      invalid_attrs = valid_attrs |> Map.delete(:url)
      changeset = Property.changeset(%Property{}, invalid_attrs)

      refute changeset.valid?
      assert changeset.errors == [url: {"can't be blank", [validation: :required]}]
    end

    test "changeset with missing property_type", %{valid_attrs: valid_attrs} do
      invalid_attrs = valid_attrs |> Map.delete(:property_type)
      changeset = Property.changeset(%Property{}, invalid_attrs)

      refute changeset.valid?
      assert changeset.errors == [property_type: {"can't be blank", [validation: :required]}]
    end

    test "changeset with missing status", %{valid_attrs: valid_attrs} do
      invalid_attrs = valid_attrs |> Map.put(:status, nil)
      changeset = Property.changeset(%Property{}, invalid_attrs)

      refute changeset.valid?
      assert changeset.errors == [status: {"can't be blank", [validation: :required]}]
    end
  end
end
