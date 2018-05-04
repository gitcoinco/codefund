defmodule Framework.Controller.AssignsError do
  defexception [:message, :key]
end

defmodule Framework.Controller.Assigns.DSL do
  @all_actions [
    [:before_hook],
    [:inject_params],
    [:after_hooks, :success],
    [:after_hooks, :error]
  ]

  defmacro __using__(_nothing) do
    [build_actions(@all_actions), create_assigns()]
  end

  @spec build_actions(list) :: Macro.t()
  defp build_actions(actions) when is_list(actions) do
    for action <- actions do
      build_action(action)
    end
  end

  @spec build_action(list) :: Macro.t()
  defp build_action(action) do
    quote do
      def unquote(List.last(action))(assigns \\ [after_hooks: []], function),
        do: Framework.Controller.Assigns.DSL.assign_or_raise(assigns, function, unquote(action))
    end
  end

  defp create_assigns() do
    quote do
      @spec assigns(list) :: list
      def assigns(assigns \\ []) do
        [assigns: assigns]
      end
    end
  end

  def assign_or_raise(assigns, function, keys) when is_list(keys) do
    case is_nil(get_in(assigns, keys)) do
      true ->
        wrapper = fn object, params -> function.(object, params) end

        assigns
        |> put_in(keys, wrapper)

      false ->
        raise exception(List.last(keys))
    end
  end

  defp exception(key) do
    %Framework.Controller.AssignsError{message: "#{key} already set on stub assigns", key: key}
  end
end

defmodule Framework.Controller.Assigns do
  use Framework.Controller.Assigns.DSL
end
