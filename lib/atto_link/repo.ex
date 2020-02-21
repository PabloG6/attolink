defmodule AttoLink.Repo do
  use Ecto.Repo,
    otp_app: :atto_link,
    adapter: Ecto.Adapters.Postgres
end
