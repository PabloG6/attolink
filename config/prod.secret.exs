# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """


stripe_test_key =
  System.get_env("STRIPE_SECRET_KEY") ||
  raise """
  environment variable STRIPE_SECRET_KEY is missing.

  """

username = System.get_env("DB_USERNAME") || 
	  raise """ 
	environment variable DB_USERNAME is  missing
	"""

password = System.get_env("DB_PASSWORD") || 
           raise """
           environment variable DB_PASSWORD is missing
           """


database = System.get_env("DB_NAME")  || 
           raise """
           environment variable DB_NAME is missing
           """

hostname = "localhost"

config :atto_link, AttoLink.Repo,
  # ssl: true,
  username: username,
  password: password,
  database: database,
  hostname: hostname, 
 
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "15")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :atto_link, AttoLinkWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

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
