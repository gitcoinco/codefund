defmodule Framework.Controller do
  def imports() do
    quote do
      import Framework.Controller.Stub, only: [defstub: 2]
      import Framework.Controller.Assigns
      import Framework.Controller.Config
    end
  end

  defmacro __using__(_none) do
    apply(__MODULE__, :imports, [])
  end
end
