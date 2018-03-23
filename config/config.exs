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
  url: [host: (System.get_env("HOST") || "localhost")],
  secret_key_base: "JdaDMqC6DEzZP5Mjm9S06nVaLaqExfN3Tyszbywe9c99Sg6RA2h7nRCVB2LFBN1n",
  render_errors: [view: CodeSponsorWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CodeSponsor.PubSub,
           adapter: Phoenix.PubSub.PG2]

import_config "./configs/*.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
