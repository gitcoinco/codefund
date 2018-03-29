defmodule CodeFundWeb.CampaignType do
  use CodeFundWeb.BaseType

  def build_form(form) do
    form
    |> add(:name, :text_input, label: "Name", validation: [:required])
    |> add(
      :redirect_url,
      :text_input,
      label: "Redirect URL",
      validation: [
        :required,
        format: [arg: ~r/^https?:\/\/.+$/, message: "must begin with http:// or https://"]
      ],
      phoenix_opts: [
        placeholder: "https://"
      ]
    )
    |> add(:status, :select, label: "Status", choices: [Pending: 1, Active: 2, Archived: 3])
    |> add(
      :description,
      :textarea,
      label: "Description",
      phoenix_opts: [rows: 4],
      required: false
    )
    |> add(
      :bid_amount,
      :number_input,
      label: "Bid Amount",
      validation: [:required],
      addon: "$",
      phoenix_opts: [
        step: "0.01",
        min: "0"
      ]
    )
    |> add(
      :budget_daily_amount,
      :number_input,
      label: "Daily Budget",
      validation: [:required],
      addon: "$",
      phoenix_opts: [
        step: "0.01",
        min: "0"
      ]
    )
    |> add(
      :budget_monthly_amount,
      :number_input,
      label: "Monthly Budget",
      validation: [:required],
      addon: "$",
      phoenix_opts: [
        step: "0.01",
        min: "0"
      ]
    )
    |> add(
      :budget_total_amount,
      :number_input,
      label: "Total Budget",
      validation: [:required],
      addon: "$",
      phoenix_opts: [
        step: "0.01",
        min: "0"
      ]
    )
    |> add(
      :save,
      :submit,
      label: "Submit",
      phoenix_opts: [
        class: "btn-primary"
      ]
    )
  end
end
