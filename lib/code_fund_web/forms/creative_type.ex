defmodule CodeFundWeb.CreativeType do
  use CodeFundWeb.BaseType

  def build_form(form) do
    form
      |> add(:name, :text_input, label: "Name", validation: [:required])
      |> add(:body, :text_input, label: "Body", validation: [:required])
      |> add(:image_url, :text_input, label: "Image URL", validation: [:required])
      |> add(:save, :submit, label: "Submit", phoenix_opts: [
        class: "btn-primary"
      ])
  end
end
