defmodule CodeSponsorWeb.TemplateController do
  use CodeSponsorWeb, :controller

  alias CodeSponsor.Creatives
  alias CodeSponsor.Creatives.Template
  alias CodeSponsorWeb.TemplateType

  plug CodeSponsorWeb.Plugs.RequireAnyRole, %{roles: ["admin"], to: "/dashboard"}

  def index(conn, _params) do
    templates = Creatives.list_templates()
    render(conn, "index.html", templates: templates)
  end

  def new(conn, _params) do
    form = create_form(TemplateType, %Template{})
    render(conn, "new.html", form: form)
  end

  def create(conn, %{"template" => template_params}) do
    TemplateType
      |> create_form(%Template{}, template_params)
      |> insert_form_data
      |> case do
        {:ok, template} ->
          conn
          |> put_flash(:info, "Template created successfully.")
          |> redirect(to: template_path(conn, :show, template))
        {:error, form} ->
          render(conn, "new.html", form: form)
      end
  end

  def show(conn, %{"id" => id}) do
    template = Creatives.get_template!(id)
    render(conn, "show.html", template: template)
  end

  def edit(conn, %{"id" => id}) do
    template = Creatives.get_template!(id)
    form = create_form(TemplateType, template)
    render(conn, "edit.html", form: form, template: template)
  end

  def update(conn, %{"id" => id, "template" => template_params}) do
    template = Creatives.get_template!(id)

    TemplateType
      |> create_form(template, template_params)
      |> update_form_data
      |> case do
        {:ok, template} ->
          conn
          |> put_flash(:info, "Template updated successfully.")
          |> redirect(to: template_path(conn, :show, template))
        {:error, form} ->
          render(conn, "edit.html", template: template, form: form)
      end
  end

  def delete(conn, %{"id" => id}) do
    template = Creatives.get_template!(id)
    {:ok, _template} = Creatives.delete_template(template)

    conn
    |> put_flash(:info, "Template deleted successfully.")
    |> redirect(to: template_path(conn, :index))
  end
end
