defmodule Controller.Config do
  @behaviour Access
  defstruct schema: "", nested: []

  def fetch(term, key) do
    term
    |> Map.from_struct()
    |> Map.fetch(key)
  end

  def get(term, key, default) do
    term
    |> Map.from_struct()
    |> Map.get(key, default)
  end

  def get_and_update(data, key, function) do
    data
    |> Map.from_struct()
    |> Map.get_and_update(key, function)
  end

  def pop(data, key) do
    data
    |> Map.from_struct()
    |> Map.pop(key)
  end
end

defmodule Framework.Controller.Config do
  defmacro defconfig(do: block) do
    quote bind_quoted: [block: block], unquote: true do
      struct(%Controller.Config{}, block)

      def config() do
        struct(%Controller.Config{}, unquote(block))
      end
    end
  end
end
