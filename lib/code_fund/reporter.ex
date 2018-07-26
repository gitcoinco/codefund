defmodule CodeFund.Reporter do
  @spec report(atom, String.t()) :: tuple
  defmacro report(level, message \\ "Runtime Error")

  defmacro report(:info, message) do
    quote do
      Sentry.capture_message(unquote(message), extra: %{level: :info})
    end
  end

  defmacro report(:warning, message) do
    quote do
      {function_name, arity} = __ENV__.function

      Sentry.capture_message(unquote(message),
        extra: %{
          level: :warning,
          function: "#{__MODULE__}##{function_name}/#{arity}",
          line: "#{__ENV__.file}:#{__ENV__.line}"
        }
      )
    end
  end

  defmacro report(:error, exception, message) do
    quote do
      {function_name, arity} = __ENV__.function

      Sentry.capture_exception(unquote(exception),
        stacktrace: __STACKTRACE__,
        extra: %{
          function: "#{__MODULE__}##{function_name}/#{arity}",
          message: unquote(message)
        }
      )
    end
  end
end
