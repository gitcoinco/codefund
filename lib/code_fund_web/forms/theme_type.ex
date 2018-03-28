defmodule CodeFundWeb.ThemeType do
  use CodeFundWeb.BaseType

  def build_form(form) do
    form
      |> add(:template_id, SelectAssoc, label: "Template", validation: [:required])
      |> add(:name, :text_input, label: "Name", validation: [:required])
      |> add(:slug, :text_input, label: "Slug", validation: [:required])
      |> add(:description, :textarea, label: "Description", phoenix_opts: [ rows: 2 ], required: false)
      |> add(:body, :textarea, label: "CSS", phoenix_opts: [ rows: 20 ], validation: [:required])
      |> add(:save, :submit, label: "Submit", phoenix_opts: [
        class: "btn-primary"
      ])
  end
end
