use Mix.Config

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: CodeSponsor.Schema.User,
  repo: CodeSponsor.Repo,
  module: CodeSponsor,
  web_module: CodeSponsorWeb,
  router: CodeSponsorWeb.Router,
  messages_backend: CodeSponsorWeb.Coherence.Messages,
  logged_out_url: "/",
  email_from_name: "Code Sponsor Team",
  email_from_email: "team@codesponsor.io",
  opts: [:authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token, :invitable, :registerable, :rememberable]

config :coherence, CodeSponsorWeb.Coherence.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: (System.get_env("MAILGUN_API_KEY") || "__MISSING__"),
  domain: (System.get_env("MAILGUN_DOMAIN") || "__MISSING__")
# %% End Coherence Configuration %%
