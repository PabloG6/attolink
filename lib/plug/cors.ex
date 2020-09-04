defmodule AttoLink.Cors do
  use Corsica.Router,
    origins: [~r{^https?://(.*\.?)teenielink\.dev$}, "http://localhost:4200"],
    allow_credentials: true,
    allow_headers: :all,
    allow_methods: :all,
    max_age: 2000

  resource "/*",
    origins: [~r{^https?://(.*\.?)teenielink\.dev}, "http://localhost:4200"],
    allow_headers: :all,
    allow_methods: :all,
    allow_credentials: true

  resource "v1/*",
    origins: "*",
    allow_headers: :all,
    allow_methods: :all,
    allow_credentials: true




end
