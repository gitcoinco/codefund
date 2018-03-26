defmodule CodeSponsorWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use CodeSponsorWeb, :controller
      use CodeSponsorWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: CodeSponsorWeb
      use Formex.Controller
      use Formex.Ecto.Controller
      import Plug.Conn
      plug RemoteIp
      import CodeSponsorWeb.Router.Helpers
      import CodeSponsorWeb.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/code_sponsor_web/templates",
                        namespace: CodeSponsorWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1, action_name: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      use Formex.View

      import CodeSponsorWeb.Router.Helpers
      import CodeSponsorWeb.ErrorHelpers
      import CodeSponsorWeb.Gettext

      import PhoenixActiveLink
      import Scrivener.HTML
      import CodeSponsorWeb.ViewHelpers
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
      alias __MODULE__
    end
  end

  def schema_with_formex do
    quote do
      use CodeSponsorWeb, :schema
      use Formex.Ecto.Schema
    end
  end

  def query do
    quote do
      import CodeSponsor.Helpers, only: [sort: 1, paginate: 4]
      import Filtrex.Type.Config
      import Ecto.Query, warn: false

      alias CodeSponsor.Repo
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import CodeSponsorWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
