defmodule CodeFundWeb.Hooks.Shared do
  @spec join_to_user_id(Plug.Conn.t(), map) :: {String.t(), String.t()}
  def join_to_user_id(conn, _params) do
    {"user_id", conn.assigns.current_user.id}
  end
end
