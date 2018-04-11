defmodule CodeFund.Emails do
  import Bamboo.Email

  def contact_form_email(%{"name" => name, "email" => email, "subject" => subject, "body" => body}) do
    new_email()
    |> to("team@codefund.io")
    |> from("#{name} <#{email}>")
    |> subject(subject)
    |> html_body(body)
    |> text_body(body)
  end
end
