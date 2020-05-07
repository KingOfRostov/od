# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :od,
  ecto_repos: [Od.Repo]

# Configures the endpoint
config :od, OdWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "P+0JG6v5umu5pQ8pWjo3Fkzlk72e9DOGAtji4wkFJu9bo/bGRDcM+FRUtwkfGol9",
  render_errors: [view: OdWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Od.PubSub,
  live_view: [signing_salt: "p+nxZ4yW"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
