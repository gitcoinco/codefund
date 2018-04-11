defmodule CodeFundWeb.PropertyType do
  use CodeFundWeb.BaseType

  def build_form(form) do
    form
    |> add(:name, :text_input, label: "Name", validation: [:required])
    |> add(
      :description,
      :textarea,
      label: "Description",
      phoenix_opts: [rows: 4],
      validation: [:required]
    )
    |> add(
      :property_type,
      :select,
      label: "Property Type",
      choices: [Website: 1, Repository: 2, Newsletter: 3],
      validation: [:required]
    )
    |> add(
      :url,
      :text_input,
      label: "URL",
      validation: [
        :required,
        format: [arg: ~r/^https?:\/\/.+$/]
      ]
    )
    |> add(
      :estimated_monthly_page_views,
      :number_input,
      label: "Est. Monthly Page Views"
    )
    |> add(
      :estimated_monthly_visitors,
      :number_input,
      label: "Est. Monthly Visitors"
    )
    |> add(
      :alexa_site_rank,
      :number_input,
      label: "Alexa Ranking"
    )
    |> add(
      :language,
      :text_input,
      label: "Language"
    )
    |> add(
      :programming_languages,
      :multiple_select,
      label: "Programming Languages",
      choices: CodeFund.Properties.programming_languages()
    )
    |> add(
      :screenshot_url,
      :text_input,
      label: "Screenshot URL",
      phoenix_opts: [
        placeholder: "https://"
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
