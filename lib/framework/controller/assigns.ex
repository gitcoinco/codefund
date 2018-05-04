defmodule Framework.Controller.AssignsError do
  defexception [:message, :key]
end

defmodule Framework.Controller.Assigns do
  @spec assigns(list) :: list
  def assigns(assigns \\ []) do
    [assigns: assigns]
  end

  @spec before_hook(list, function) :: list
  def before_hook(assigns \\ [after_hooks: []], function)

  def before_hook([before_hook: before_hook], _function) when not is_nil(before_hook) do
    raise exception("before_hook")
  end

  def before_hook(assigns, function) do
    wrapper = fn conn, params -> function.(conn, params) end

    assigns
    |> Keyword.put(:before_hook, wrapper)
  end

  @spec inject_params(list, function) :: list
  def inject_params(assigns \\ [after_hooks: []], function)

  def inject_params([params: params], _function) when not is_nil(params) do
    raise exception("params")
  end

  def inject_params(assigns, function) do
    wrapper = fn conn, params ->
      function.(conn, params)
    end

    assigns
    |> Keyword.put(:params, wrapper)
  end

  @spec success(list, function) :: list
  def success(assigns \\ [after_hooks: []], function)

  def success([after_hooks: [success: success]], _function) when not is_nil(success) do
    raise exception("success")
  end

  def success(assigns, function) do
    wrapper = fn object, params -> function.(object, params) end

    assigns
    |> put_in([:after_hooks, :success], wrapper)
  end

  @spec error(list, function) :: list
  def error(assigns \\ [after_hooks: []], function)

  def error([after_hooks: [error: error]], _function) when not is_nil(error) do
    raise exception("error")
  end

  def error(assigns, function) do
    wrapper = fn conn, params -> function.(conn, params) end

    assigns
    |> put_in([:after_hooks, :error], wrapper)
  end

  defp exception(key) do
    %Framework.Controller.AssignsError{message: "#{key} already set on stub assigns", key: key}
  end
end
