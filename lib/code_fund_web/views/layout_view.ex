defmodule CodeFundWeb.LayoutView do
  use CodeFundWeb, :view

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

  def current_user_gravatar_url(conn) do
    if Coherence.logged_in?(conn) do
      current_user = Coherence.current_user(conn)
      gravatar_url(current_user.email)
    else
      ""
    end
  end

  def current_user_email(conn) do
    if Coherence.logged_in?(conn) do
      current_user = Coherence.current_user(conn)
      current_user.email
    else
      ""
    end
  end

  def flash_element(conn) do
    flash_json = Poison.encode!(get_flash(conn))
    content_tag(:div, "", [{:data, [flash: flash_json, controller: "flash"]}])
  end
end
