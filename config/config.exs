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

import_config "./configs/*.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: CodeSponsor.Coherence.User,
  repo: CodeSponsor.Repo,
  module: CodeSponsor,
  web_module: CodeSponsorWeb,
  router: CodeSponsorWeb.Router,
  messages_backend: CodeSponsorWeb.Coherence.Messages,
  logged_out_url: "/",
  opts: [:authenticatable]
# %% End Coherence Configuration %%
