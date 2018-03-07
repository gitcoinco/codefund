defmodule CodeSponsor.Constants do
  @moduledoc """
  Helps you define constants easily. Credit to http://kiprosh.com/blog/constant-in-elixir

  ## Examples

      defmodule CodeSponsor.Clicks.Click do
        import CodeSponsor.Constants
      
        const :statuses, %{
          pending: 0,
          redirected: 1
        }
      end
      
      CodeSponsor.Clicks.Click.statuses[:pending]  # You can use this line anywhere

  """
  defmacro const(const_name, const_value) do
    quote do
      def unquote(const_name)(), do: unquote(const_value)
    end
  end
end