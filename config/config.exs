# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :atto_link,
  ecto_repos: [AttoLink.Repo]

# Configures the endpoint
config :atto_link, AttoLinkWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kLKLUQtidA+8vG6KEbxjPtoQmSWwAm8RpF4iM62cAoHaR12QQUJTvxiD8MMedqGU",
  render_errors: [view: AttoLinkWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: AttoLink.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "ZE47PxVK"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
config :tesla, adapter: Tesla.Adapter.Hackney

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
