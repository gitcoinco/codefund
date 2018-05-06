defmodule CodeFundWeb.ThemeController do
  use CodeFundWeb, :controller
  use Framework.Controller

  use Framework.Controller.Stub.Definitions, [
    :all,
    except: [:new, :update, :create, :edit]
  ]

  defconfig do
    [schema: "Theme"]
  end

  alias Framework.Phoenix.Form.Helpers, as: FormHelpers
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin"])

  defstub new do
    assigns(template_choices: controller_assigns())
  end

  defstub edit do
    assigns(template_choices: controller_assigns())
  end

  defstub update do
    assigns(template_choices: controller_assigns())
  end

  defstub create do
    assigns(template_choices: controller_assigns())
  end

  defp controller_assigns() do
    CodeFund.Templates.list_templates() |> FormHelpers.repo_objects_to_options()
  end
end
