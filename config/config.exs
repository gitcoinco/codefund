# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :code_sponsor,
  ecto_repos: [CodeSponsor.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :code_sponsor, CodeSponsorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: CodeSponsorWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CodeSponsor.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :money,
  default_currency: :USD,
  separator: ",",
  delimeter: ".",
  symbol: true,
  symbol_on_right: false,
  symbol_space: false

config :exq,
  name: Exq,
  host: System.get_env("DATA_REDIS_HOST"),
  port: 6379,
  # password: System.get_env("DATA_REDIS_PASSWORD"),
  namespace: "exq",
  concurrency: :infinite,
  queues: [
    {"cs_high", 50},
    {"cs_default", 10},
    {"cs_low", 1}
  ],
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  max_retries: 5,
  shutdown_timeout: 5000

config :exq_ui,
  server: true

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: CodeSponsor.Coherence.User,
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
  api_key: System.get_env("MAILGUN_API_KEY"),
  domain: System.get_env("MAILGUN_DOMAIN")
# %% End Coherence Configuration %%

config :formulator,
  translate_error_module: CodeSponsorWeb.ErrorHelpers,
  validate: true,
  validate_regex: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
