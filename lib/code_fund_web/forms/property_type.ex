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
      choices: [
        Website: 1,
        "Repository (not yet supported)": 2,
        "Newsletter (not yet supported)": 3
      ],
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
    |> CodeFundWeb.Form.Helpers.add_if_role(
      Keyword.fetch!(form.opts, :current_user).roles,
      ["admin"],
      fn form ->
        form
        |> add(
          :status,
          :select,
          label: "Status",
          choices: CodeFund.Properties.statuses(),
          validation: [:required]
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
          choices: CodeFund.Properties.programming_languages(),
          phoenix_opts: [
            class: "form-control selectize"
          ]
        )
        |> add(
          :topic_categories,
          :multiple_select,
          label: "Topic Categories",
          choices: CodeFund.Properties.topic_categories(),
          phoenix_opts: [
            class: "form-control selectize"
          ]
        )
        |> add(
          :screenshot_url,
          :text_input,
          label: "Screenshot URL",
          phoenix_opts: [
            placeholder: "https://"
          ]
        )
      end
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
