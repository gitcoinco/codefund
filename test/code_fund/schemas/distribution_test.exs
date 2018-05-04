defmodule CodeFund.Schema.DistributionTest do
  use CodeFund.DataCase
  alias CodeFund.Schema.Distribution
  import CodeFund.Factory

  describe "distributions" do
    setup do
      valid_attrs = build(:distribution) |> Map.from_struct()
      {:ok, %{valid_attrs: valid_attrs}}
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      valid_attrs = valid_attrs |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
      assert Distribution.changeset(%Distribution{}, valid_attrs).valid?
    end

    test "changeset with missing required attributes", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.required_attribute_test(
        Distribution,
        Distribution.required(),
        valid_attrs
      )
    end
  end
end
