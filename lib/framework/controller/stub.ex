defmodule Framework.Controller.Stub do
  import Framework.Controller.Stub.Definitions, only: [build_action: 3]
  @spec defstub(atom, list) :: Macro.t()
  defmacro defstub(definition, do: block) do
    config =
      quote do
        __MODULE__.config()
      end

    {function, []} = Macro.decompose_call(definition)
    build_action(config, function, block)
  end
end
