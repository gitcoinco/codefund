defmodule CodeFundWeb.Email.AuthRequest do
  use Bamboo.Phoenix, view: CodeFundWeb.EmailView

  @spec email(String.t(), String.t(), Plug.Conn.t()) :: Bamboo.Email.t()
  def email(token, email, conn) do
    new_email()
    |> put_text_layout({CodeFundWeb.LayoutView, "auth_request.text"})
    |> put_html_layout({CodeFundWeb.LayoutView, "auth_request.html"})
    |> to(email)
    |> from("CodeFund <no-reply@codefund.io>")
    |> subject("Finish Your CodeFund Integration")
    |> assign(:conn, conn)
    |> assign(:token, token)
    |> assign(:email, email)
    |> render(:form_submission)
  end
end
