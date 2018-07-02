defmodule CodeFundWeb.Authentication.PasswordlessController do
  use CodeFundWeb, :controller
  use Framework.Controller

  alias CodeFund.Mailer
  alias CodeFundWeb.Email.AuthRequest

  @spec new(Plug.Conn.t(), map) :: Plug.Conn.t()
  def new(conn, _params) do
    render(
      conn,
      "new.html"
    )
  end

  @spec send(Plug.Conn.t(), map) :: Plug.Conn.t()
  def send(conn, %{"first_name" => first_name, "last_name" => last_name, "email" => email}) do
    {:ok, token} =
      email |> String.replace(~r/\+/, "%2B") |> Authentication.Token.sign(first_name, last_name)

    token
    |> AuthRequest.email(email, conn)
    |> Mailer.deliver_now()

    conn
    |> put_flash(:info, "Your request was submitted successfully.")
    |> render("success.html", token: token, email: email)
  end

  @spec complete(Plug.Conn.t(), map) :: Plug.Conn.t()
  def complete(conn, %{"email" => email, "token" => token}) do
    encoded_email = email |> String.replace(~r/\+/, "%2B")

    with {:ok, [^email, first_name, last_name]} <-
           encoded_email |> Authentication.Token.verify(token),
         nil <- CodeFund.Users.get_by_email(email) do
      uuid = UUID.uuid4()

      registration_params = %{
        "email" => email,
        "first_name" => first_name,
        "last_name" => last_name,
        "roles" => ["developer"],
        "password" => uuid,
        "password_confirmation" => uuid
      }

      user_schema = Coherence.Config.user_schema()

      {:ok, new_user} =
        :registration
        |> Coherence.ControllerHelpers.changeset(
          user_schema,
          user_schema.__struct__,
          registration_params
        )
        |> Coherence.Schemas.create()

      redirect_or_login(conn, new_user)
    else
      {:error, _reason} -> redirect(conn, external: dashboard_url(conn, :index))
      %CodeFund.Schema.User{} = user -> redirect_or_login(conn, user)
    end
  end

  defp redirect_or_login(conn, user) do
    conn
    |> Coherence.ControllerHelpers.login_user(user)
    |> put_flash(:info, "Successfully logged in.")
    |> redirect(external: dashboard_url(conn, :index))
  end
end
