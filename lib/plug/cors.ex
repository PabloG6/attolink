defmodule AttoLink.Cors do
  use Corsica.Router,
    origins: Application.get_env(:atto_link, :origins),
    allow_credentials: true,
    allow_headers: :all,
    allow_methods: :all,
    max_age: 2000

  resource "/*",
    origins: Application.get_env(:atto_link, :origins),
    allow_headers: :all,
    allow_methods: :all,
    allow_credentials: true

  resource "v1/*",
    origins: "*",
    allow_headers: :all,
    allow_methods: :all,
    allow_credentials: true




end
