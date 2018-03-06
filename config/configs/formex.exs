use Mix.Config

config :formex,
  repo: CodeSponsor.Repo,
  validator: Formex.Ecto.ChangesetValidator,
  translate_error: &CodeSponsorWeb.ErrorHelpers.translate_error/1,  # optional, from /lib/app_web/views/error_helpers.ex
  template: CodeSponsorWeb.Formex.BootstrapHorizontal,              # optional, can be overridden in a template
  template_options: [                                               # optional, can be overridden in a template
    left_column: "col-sm-2",
    right_column: "col-sm-10"
  ]