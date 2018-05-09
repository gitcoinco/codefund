defmodule SharedExample.ModelTests do
  import ExUnit.Assertions

  @spec required_attribute_test(atom, list, map) :: list
  def required_attribute_test(schema, required_attributes, valid_attrs) do
    for required_attribute <- required_attributes do
      invalid_attrs = valid_attrs |> Map.put(required_attribute, nil)
      changeset = apply(schema, :changeset, [struct(schema), invalid_attrs])

      assert changeset.errors |> Keyword.fetch!(required_attribute) ==
               {"can't be blank", [validation: :required]}
    end
  end

  @spec url_validation_test(atom, atom, map) :: boolean
  def url_validation_test(schema, field_to_test, valid_attrs) do
    invalid_attrs = valid_attrs |> Map.put(field_to_test, "narf")
    changeset = apply(schema, :changeset, [struct(schema), invalid_attrs])
    refute changeset.valid?

    assert changeset.errors == [
             {field_to_test, {"is missing a scheme (e.g. https)", [validation: :format]}}
           ]
  end

  @spec length_validation_test(atom, list, map) :: list
  def length_validation_test(schema, attributes, valid_attrs) do
    for attribute <- attributes do
      invalid_attrs = valid_attrs |> Map.put(attribute, [])
      changeset = apply(schema, :changeset, [struct(schema), invalid_attrs])

      assert changeset.errors |> Keyword.fetch!(attribute) ==
               {"should have at least %{count} item(s)", [count: 1, validation: :length, min: 1]}
    end
  end
end
