defmodule CodeFundWeb.TemplateController do
  use CodeFundWeb, :controller

  alias CodeFund.Creatives
  alias CodeFund.Schema.Template
  alias CodeFundWeb.TemplateType

  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin"])

  def index(conn, params) do
    case Creatives.paginate_templates(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        report(:error)

        conn
        |> put_flash(:error, "There was an error rendering templates. #{inspect(error)}")
        |> redirect(to: template_path(conn, :index))
    end
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
        report(:warn, "Changeset Error")
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
        report(:warn, "Changeset Error")
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
