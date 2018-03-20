defmodule CodeSponsorWeb.ThemeType do
  use CodeSponsorWeb.BaseType

  def build_form(form) do
    form
      |> add(:name, :text_input, label: "Name", validation: [:required])
      |> add(:slug, :text_input, label: "Slug", validation: [:required])
      |> add(:description, :textarea, label: "Description", phoenix_opts: [ rows: 2 ], required: false)
      |> add(:body, :textarea, label: "HTML", phoenix_opts: [ rows: 20 ], validation: [:required])
      |> add(:save, :submit, label: "Submit", phoenix_opts: [
        class: "btn-primary"
      ])
  end
end
