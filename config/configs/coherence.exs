use Mix.Config

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: CodeFund.Schema.User,
  repo: CodeFund.Repo,
  module: CodeFund,
  web_module: CodeFundWeb,
  router: CodeFundWeb.Router,
  messages_backend: CodeFundWeb.Coherence.Messages,
  logged_out_url: "/",
  login_field: :email,
  email_from_name: "CodeFund Team",
  email_from_email: "team@codesponsor.io",
  opts: [
    :authenticatable,
    :recoverable,
    :lockable,
    :trackable,
    :unlockable_with_token,
    :invitable,
    :registerable,
    :rememberable
  ]

config :coherence, CodeFundWeb.Coherence.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: System.get_env("MAILGUN_API_KEY") || "__MISSING__",
  domain: System.get_env("MAILGUN_DOMAIN") || "__MISSING__"

# %% End Coherence Configuration %%
