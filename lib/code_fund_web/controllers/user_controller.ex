defmodule CodeFundWeb.UserController do
  use CodeFundWeb, :controller
  import Ecto.Query
  alias CodeFund.Repo
  alias CodeFund.Schema.User
  use Framework.Controller
  use Framework.Controller.Stub.Definitions, [:show]

  plug(
    CodeFundWeb.Plugs.RequireOwnership,
    [roles: ["admin"]] when action in [:show, :edit, :update, :refresh_api_key, :revoke_api_key]
  )

  plug(
    CodeFundWeb.Plugs.RequireAnyRole,
    [roles: ["admin"]] when action in [:index, :masquerade]
  )

  use Coherence.Config

  defconfig do
    [schema: "User"]
  end

  def index(conn, _params) do
    render(
      conn,
      "index.html",
      users: Repo.all(from(u in User, preload: [:properties], order_by: u.first_name))
    )
  end

  defstub edit do
    before_hook(&fields/2)
  end

  defstub update do
    error(&fields/2)
  end

  def refresh_api_key(conn, params) do
    CodeFund.Users.get_user!(params["user_id"])
    |> CodeFund.Users.update_user(%{api_key: Framework.API.generate_api_key()})

    conn
    |> put_flash(:notice, "API Key has been successfully updated.")
    |> redirect(external: get_referer(conn))
  end

  def revoke_api_key(conn, params) do
    CodeFund.Users.get_user!(params["user_id"])
    |> CodeFund.Users.update_user(%{api_key: nil})

    conn
    |> put_flash(:notice, "API Key has been successfully revoked.")
    |> redirect(external: get_referer(conn))
  end

  def masquerade(conn, %{"id" => user_id}) do
    Repo.get(User, user_id)
    |> handle_masquerade(conn)
    |> put_session("admin_user", conn.assigns.current_user)
    |> put_flash(:notice, "You have successfully begun masquerading.")
    |> redirect(to: dashboard_path(conn, :index))
  end

  def end_masquerade(conn, _params) do
    conn
    |> get_session("admin_user")
    |> handle_masquerade(conn)
    |> delete_session("admin_user")
    |> put_flash(:notice, "You have successfully ended masquerading.")
    |> redirect(to: dashboard_path(conn, :index))
  end

  defp fields(conn, _) do
    fields = [
      first_name: [type: :text_input, label: "First Name"],
      last_name: [type: :text_input, label: "Last Name"],
      email: [type: :email_input, label: "Email"],
      company: [type: :text_input, label: "Company"],
      address_1: [type: :text_input, label: "Street Address"],
      address_2: [type: :text_input, label: "Suite/Apt"],
      city: [type: :text_input, label: "City"],
      region: [type: :text_input, label: "Region"],
      postal_code: [type: :text_input, label: "Postal Code"],
      country: [type: :text_input, label: "Country"],
      roles: [
        type: :multiple_select,
        label: "Roles",
        opts: [choices: CodeFund.Users.roles(), class: "form-contol selectize"]
      ],
      revenue_rate: [
        type: :percentage_input,
        label: "Revenue Rate",
        opts: [step: "0.01", max: "1.0"]
      ]
    ]

    fields =
      case conn.assigns.current_user.roles |> CodeFund.Users.has_role?(["admin"]) do
        true ->
          fields
          |> Enum.concat(api_access: [type: :checkbox, label: "Enable API Access"])

        false ->
          fields
      end

    [fields: fields]
  end

  defp get_referer(conn) do
    case get_req_header(conn, "referer") do
      [referer] -> referer
      _ -> dashboard_url(conn, :index)
    end
  end

  defp handle_masquerade(user, conn) do
    Config.auth_module()
    |> apply(Config.create_login(), [conn, user, [id_key: Config.schema_key()]])
  end
end
