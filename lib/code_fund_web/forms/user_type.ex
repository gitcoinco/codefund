defmodule CodeFundWeb.UserType do
  use CodeFundWeb.BaseType

  def build_form(form) do
    form
    |> add(:first_name, :text_input, label: "First Name", validation: [:required])
    |> add(:last_name, :text_input, label: "Last Name", validation: [:required])
    |> add(:email, :email_input, label: "Email", validation: [:required])
    |> add(:address_1, :text_input, label: "Street Address", required: false)
    |> add(:address_2, :text_input, label: "Suite/Apt", required: false)
    |> add(:city, :text_input, label: "City", required: false)
    |> add(:region, :text_input, label: "State/Region", required: false)
    |> add(:postal_code, :text_input, label: "Postal Code", required: false)
    |> add(:country, :text_input, label: "Country", required: false)
    |> add(
      :roles,
      :multiple_select,
      label: "Roles",
      choices: CodeFund.Users.roles(),
      validation: [:required]
    )
    |> add(
      :revenue_rate,
      :number_input,
      label: "Revenue Rate",
      validation: [:required],
      addon: "%",
      phoenix_opts: [
        step: "0.01",
        min: "0"
      ]
    )
    |> add(:save, :submit, label: "Submit", phoenix_opts: [class: "btn-primary"])
  end
end
