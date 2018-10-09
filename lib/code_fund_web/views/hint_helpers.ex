defmodule CodeFundWeb.HintHelpers do
  @moduledoc """
  Conveniences for translating and building hint messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input hints.
  """
  def hint_tag(nil) do
    []
  end

  def hint_tag(hint) do
    [content_tag(:small, raw(hint), class: "form-text text-muted")]
  end

  def hint_tag_html(nil) do
    ""
  end

  def hint_tag_html(hint) do
    content_tag(:small, raw(hint), class: "form-text text-muted")
  end
end
