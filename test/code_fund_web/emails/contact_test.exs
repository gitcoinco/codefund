defmodule CodeFundWeb.Email.ContactTest do
  use ExUnit.Case
  use Bamboo.Test
  alias CodeFundWeb.Email.Contact

  test "email" do
    email =
      Contact.email(
        %{
          "first_name" => "Mr.",
          "last_name" => "Bean",
          "email" => "duder@example.com",
          "message" => "hey sup"
        },
        "advertiser"
      )

    assert email.assigns == %{
             attrs: %{
               "email" => "duder@example.com",
               "first_name" => "Mr.",
               "last_name" => "Bean",
               "message" => "hey sup"
             }
           }

    assert email.html_body =~ "<th>Message</th>\n    <td>hey sup</td>"
    assert email.text_body =~ "------- Message -------\n\nhey sup\n\n"

    assert email.to == "team@codefund.io"
    assert email.subject == "Advertiser form submission by Mr. Bean"
  end
end
