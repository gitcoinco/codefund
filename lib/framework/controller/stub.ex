defmodule Framework.Controller.Stub do
  import Framework.Controller.Stub.Definitions, only: [build_action: 3]
  @spec defstub(atom, list) :: Macro.t()
  defmacro defstub(definition, do: block) do
    {function, [schema]} = Macro.decompose_call(definition)
    build_action(schema, function, block)
  end
end
