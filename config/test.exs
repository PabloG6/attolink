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
