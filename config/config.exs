# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :code_fund,
  ecto_repos: [CodeFund.Repo],
  generators: [binary_id: true],
  metabase_dashboard_mappings: [admin: 1, sponsor: 3, user: 2],
  freshchat_token: System.get_env("FRESHCHAT_TOKEN") || ""

# Configures the endpoint
config :code_fund, CodeFundWeb.Endpoint,
  url: [host: System.get_env("HOST") || "localhost"],
  secret_key_base: "JdaDMqC6DEzZP5Mjm9S06nVaLaqExfN3Tyszbywe9c99Sg6RA2h7nRCVB2LFBN1n",
  render_errors: [view: CodeFundWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CodeFund.PubSub, adapter: Phoenix.PubSub.PG2]

config :code_fund, CodeFund.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: System.get_env("MAILGUN_API_KEY") || "MISSING",
  domain: System.get_env("MAILGUN_DOMAIN") || "MISSING"

import_config "./configs/*.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
