defmodule CodeFundWeb.Email.AuthRequestTest do
  use CodeFundWeb.ConnCase
  use Bamboo.Test
  alias CodeFundWeb.Email.AuthRequest

  setup do
    {:ok, token} = Authentication.Token.sign("some_dude@example.com", "Some", "Dude")
    {:ok, %{token: token}}
  end

  test "email", %{token: token, conn: conn} do
    email = AuthRequest.email(token, "some_dude@example.com", conn)

    assert email.assigns.conn == conn
    assert email.assigns.token == token
    assert email.assigns.email == "some_dude@example.com"

    assert email.html_body =~ "Click here to finish your integration."

    assert email.html_body =~
             "<a href=\"/integrations/complete?email=some_dude%40example.com&amp;token="

    assert email.text_body =~ "Click here to finish your integration."

    assert email.text_body =~
             "<a href=\"/integrations/complete?email=some_dude%40example.com&amp;token="

    assert email.to == "some_dude@example.com"
    assert email.from == "CodeFund <no-reply@codefund.io>"
    assert email.subject == "Finish Your CodeFund Integration"
  end
end
