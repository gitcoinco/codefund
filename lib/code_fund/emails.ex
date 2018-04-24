defmodule CodeFund.Emails do
  use Bamboo.Phoenix, view: CodeFundWeb.EmailView

  def contact_form_email(
        %{
          "name" => name,
          "email" => email
        } = attrs
      ) do
    base_email()
    |> to("team@codefund.io")
    |> from("#{name} <#{email}>")
    |> subject("Contact form submission by #{name}")
    |> assign(:attrs, attrs)
    |> render(:form_submission)
  end

  def advertiser_form_email(
        %{
          "first_name" => first_name,
          "last_name" => last_name,
          "email" => email
        } = attrs
      ) do
    IO.inspect(attrs)

    base_email()
    |> to("team@codefund.io")
    |> from("#{first_name} #{last_name} <#{email}>")
    |> subject("Advertiser form submission by #{first_name} #{last_name}")
    |> assign(:attrs, attrs)
    |> render(:form_submission)
  end

  def publisher_form_email(
        %{
          "first_name" => first_name,
          "last_name" => last_name,
          "email" => email
        } = attrs
      ) do
    base_email()
    |> to("team@codefund.io")
    |> from("#{first_name} #{last_name} <#{email}>")
    |> subject("Publisher form submission by #{first_name} #{last_name}")
    |> assign(:attrs, attrs)
    |> render(:form_submission)
  end

  defp base_email do
    new_email()
    |> put_text_layout({CodeFundWeb.LayoutView, "email.text"})
    |> put_html_layout({CodeFundWeb.LayoutView, "email.html"})
    |> put_layout({CodeFundWeb.LayoutView, :email})
  end
end
