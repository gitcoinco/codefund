defmodule Framework.Path do
  import Framework.Module
  import Plug.Conn

  @spec construct_path(%Plug.Conn{}, atom) :: String.t()
  def construct_path(conn, :index) do
    conn
    |> assign(:object, nil)
    |> assign(:action, :index)
    |> construct_path()
  end

  def construct_path(conn, action),
    do: apply(CodeFundWeb.Router.Helpers, path(conn), build_params(conn) |> action(action))

  @spec construct_path(%Plug.Conn{}) :: String.t()
  def construct_path(conn),
    do:
      apply(
        CodeFundWeb.Router.Helpers,
        path(conn),
        build_params(conn) |> action(conn.assigns.action)
      )

  @spec build_params(Plug.Conn.t()) :: list
  defp build_params(%Plug.Conn{assigns: %{associations: associations, object: nil}} = conn) do
    Enum.concat(base(conn), associations)
  end

  defp build_params(%Plug.Conn{assigns: %{associations: associations, object: object}} = conn)
       when is_map(object) do
    Enum.concat(base(conn), associations) |> Enum.concat([object])
  end

  defp build_params(%Plug.Conn{assigns: %{associations: associations}} = conn) do
    Enum.concat(base(conn), associations)
  end

  defp build_params(%Plug.Conn{assigns: %{object: nil}} = conn) do
    base(conn)
  end

  defp build_params(%Plug.Conn{assigns: %{object: object}} = conn) when is_map(object) do
    Enum.concat(base(conn), [object])
  end

  defp build_params(%Plug.Conn{} = conn) do
    base(conn)
  end

  @spec base(Plug.Conn.t()) :: list
  defp base(conn) do
    [conn]
  end

  @spec action(list, atom) :: list
  defp action(params, action), do: params |> List.insert_at(1, action)

  @spec path(Plug.Conn.t()) :: String.t()
  defp path(conn) do
    :"#{fully_qualified(conn) |> Macro.underscore() |> String.replace("/", "_")}_path"
  end
end
