defmodule CodeFundWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use CodeFundWeb, :controller
      use CodeFundWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: CodeFundWeb
      import Plug.Conn
      plug(RemoteIp)
      import CodeFund.Reporter
      import CodeFundWeb.Router.Helpers
      import CodeFundWeb.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/code_fund_web/templates",
        namespace: CodeFundWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, action_name: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML
      import Framework.Phoenix.Form.Helpers

      import Framework.Module
      import Framework.Path

      import CodeFundWeb.Router.Helpers
      import CodeFundWeb.ErrorHelpers
      import CodeFundWeb.Gettext

      import PhoenixActiveLink
      import Scrivener.HTML
      import CodeFundWeb.ViewHelpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Query
      import Ecto.Changeset
      import Validation.URL
      alias __MODULE__
    end
  end

  def query do
    quote do
      import CodeFund.Helpers, only: [sort: 1, paginate: 4]
      import Filtrex.Type.Config
      import Ecto.Query, warn: false

      alias CodeFund.Repo
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import CodeFundWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
