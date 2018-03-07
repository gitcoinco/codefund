defmodule CodeSponsorWeb.SponsorshipType do
  use CodeSponsorWeb.BaseType

  def build_form(form) do
    form
      |> add(:campaign_id, SelectAssoc, label: "Campaign", validation: [:required])
      |> add(:property_id, SelectAssoc, label: "Property", validation: [:required])
      |> add(:bid_amount, :number_input,
        label: "CPC",
        validation: [:required],
        addon: "$",
        phoenix_opts: [
          step: "0.01",
          min: "0"
        ])
      |> add(:redirect_url, :text_input,
        label: "URL",
        validation: [
          :required,
          format: [arg: ~r/^https?:\/\/.+$/]
        ])
      |> add(:override_revenue_rate, :number_input,
        label: "Revenue Rate (override)",
        validation: [:required],
        phoenix_opts: [
          step: "0.001",
          min: "0"
        ])
      |> add(:save, :submit, label: "Submit", phoenix_opts: [
        class: "btn-primary"
      ])
  end
end
