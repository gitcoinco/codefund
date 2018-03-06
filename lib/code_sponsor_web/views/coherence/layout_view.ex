defmodule CodeSponsorWeb.Coherence.LayoutView do
  use CodeSponsorWeb.Coherence, :view

  import Phoenix.Controller, only: [view_module: 1, action_name: 1]

  @doc """
  Calls the `title` fn of the current `view_module` with the performed `:action` as arg.
  If no fun exists/matches the `default` title is returned instead.
  """
  def title(conn, default) do
    try do
      apply(view_module(conn), :title, [action_name(conn)])
    rescue
      _ -> default
    end
  end

  @doc """
  Calls the `body_class` fn of the current `view_module` with the performed `:action` as arg.
  If no fun exists/matches the `default` body class is returned instead.
  """
  def body_class(conn, default) do
    try do
      apply(view_module(conn), :body_class, [action_name(conn)])
    rescue
      _ -> default
    end
  end
end
