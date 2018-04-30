defmodule CodeFundWeb.PropertyController do
  @module "Property"

  use CodeFundWeb, :controller
  use Framework.CRUDControllerFunctions, [@module, [:index, :show, :delete]]
  import Framework.CRUDControllerFunctions, only: [defstub: 2]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "developer"])

  defstub new(@module) do
    [hooks: fn conn, params -> fields(conn, params) end]
  end

  defstub create(@module) do
    [hooks: fn conn, params -> fields(conn, params) end]
  end

  defstub edit(@module) do
    [hooks: fn conn, params -> fields(conn, params) end]
  end

  defstub update(@module) do
    [hooks: fn conn, params -> fields(conn, params) end]
  end

  defp fields(conn, _params) do
    fields = [
      name: [type: :text_input, label: "Name"],
      description: [type: :textarea, label: "Description", opts: [rows: 4]],
      property_type: [
        type: :select,
        label: "Property Type",
        opts: [
          choices: [
            Website: 1,
            "Repository (not yet supported)": 2,
            "Newsletter (not yet supported)": 3
          ]
        ]
      ],
      url: [type: :text_input, label: "URL", opts: [placeholder: "https://"]]
    ]

    fields =
      case conn.assigns.current_user.roles |> CodeFund.Users.has_role?(["admin"]) do
        true -> Enum.concat(fields, admin_fields())
        false -> fields
      end

    [fields: fields]
  end

  defp admin_fields() do
    [
      status: [type: :select, label: "Status", opts: [choices: CodeFund.Properties.statuses()]],
      estimated_monthly_page_views: [type: :number_input, label: "Est. Monthly Page Views"],
      estimated_monthly_visitors: [type: :number_input, label: "Est. Monthly Visitors"],
      alexa_site_rank: [type: :number_input, label: "Alexa Ranking"],
      language: [type: :text_input, label: "Language"],
      programming_languages: [
        type: :multiple_select,
        label: "Programming Languages",
        opts: [
          class: "form-control selectize",
          choices: CodeFund.Properties.programming_languages()
        ]
      ],
      topic_categories: [
        type: :multiple_select,
        label: "Topic Categories",
        opts: [class: "form-control selectize", choices: CodeFund.Properties.topic_categories()]
      ],
      screenshot_url: [
        type: :text_input,
        label: "Screenshot URL",
        opts: [placeholder: "https://"]
      ]
    ]
  end
end
