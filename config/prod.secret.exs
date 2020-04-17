# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config



stripe_test_key =
  "sk_test_VjpBvPBlY27yLOXU8r5lZEKi005iVURh37"

username =
  System.get_env("DB_USERNAME") ||
  raise """
  DB_USERNAME does not exist.
  """
password =
  System.get_env("DB_PASSWORD") ||
  raise """
    DB_PASSWORD does not exist as system environment variable
  """

database =
  System.get_env("DB_NAME") ||
  raise """
    DB_NAME does not exist as a system environment variable
  """

hostname = "localhost"

config :atto_link, AttoLink.Repo,
  # ssl: true,
  username: username,
  password: password,
  database: database,
  hostname: hostname,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "15")


config :stripity_stripe, api_key: stripe_test_key

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :atto_link, AttoLinkWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
