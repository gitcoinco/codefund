defmodule CodeSponsorWeb.PropertyType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:name, :text_input, label: "Name", validation: [presence: true])
    |> add(:description, :textarea, label: "Description", phoenix_opts: [ rows: 4 ], required: false)
    |> add(:property_type, :select, label: "Propety Type", choices: ["Website": 1, "Repository": 2, "Newsletter": 3], validation: [presence: true])
    |> add(:url, :text_input, label: "URL", validation: [presence: true, format: ~r/^https?:\/\/.+$/])
    |> add(:legacy_id, :text_input, label: "Legacy ID", required: false)
    |> add(:save, :submit, label: "Submit", phoenix_opts: [
      class: "btn-primary"
    ])
  end
end
