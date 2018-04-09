defmodule CodeFund.Reporter do
  @spec report(atom, String.t()) :: atom
  defmacro report(level, message \\ "Runtime Error")

  defmacro report(:warn, message) do
    quote do
      fn ->
        {function_name, arity} = __ENV__.function

        Rollbax.report_message(:warning, unquote(message), %{
          function: "#{__MODULE__}##{function_name}/#{arity}",
          line: "#{__ENV__.file}:#{__ENV__.line}"
        })
      end
      |> CodeFund.Reporter.check_env()
    end
  end

  defmacro report(:error, message) do
    quote do
      fn ->
        {function_name, arity} = __ENV__.function

        Rollbax.report(:error, "#{__MODULE__}##{function_name}/#{arity}", System.stacktrace(), %{
          message: unquote(message)
        })
      end
      |> CodeFund.Reporter.check_env()
    end
  end

  @spec check_env(function) :: atom
  def check_env(function) do
    case Mix.env() do
      :prod -> function.()
      _other -> :ok
    end
  end
end
