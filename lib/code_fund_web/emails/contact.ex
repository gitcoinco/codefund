defmodule CodeFundWeb.Email.Contact do
  use Bamboo.Phoenix, view: CodeFundWeb.EmailView

  def email(
        %{
          "first_name" => first_name,
          "last_name" => last_name,
          "email" => email
        } = attrs,
        type
      ) do
    new_email()
    |> put_text_layout({CodeFundWeb.LayoutView, "email.text"})
    |> put_html_layout({CodeFundWeb.LayoutView, "email.html"})
    |> put_layout({CodeFundWeb.LayoutView, :email})
    |> to("team@codefund.io")
    |> from(" #{first_name} #{last_name} <#{email}>")
    |> subject("#{type |> String.capitalize()} form submission by #{first_name} #{last_name}")
    |> assign(:attrs, attrs)
    |> render(:form_submission)
  end
end
