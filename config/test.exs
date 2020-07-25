use Mix.Config

# Configure your database
config :atto_link, AttoLink.Repo,
  username: "postgres",
  password: "postgres",
  database: "atto_link_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :atto_link, AttoLinkWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
config :bcrypt_elixir, :log_rounds, 4

config :hammer,
  backend:
    {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60, cleanup_interval_ms: 60_000 * 10, pool_size: 2]}

config :sendgrid,
  api_key: "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",
  sandbox_enable: true

config :atto_link,
  base_url: "http:/localhost:4200",
  free: "price_1H8H7KFiqLhwiC9fl9kxFrpW",
  basic: "price_1H8H7KFiqLhwiC9fUtcdn0h4",
  premium: "price_1H8H7KFiqLhwiC9fx4UiekeA",
  enterprise: "price_1H8H7KFiqLhwiC9ffzPAIGcy"
