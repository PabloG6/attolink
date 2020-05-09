defmodule AttoLink.MixProject do
  use Mix.Project

  def project do
    [
      app: :atto_link,
      version: "0.1.0",
      elixir: "~> 1.10.2",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      releases: releases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  defp releases do
    [
      staging: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent],
        path: "/home/deploy/phx/atto_link/releases"
      ]
    ]
  end

  def application do
    [
      mod: {AttoLink.Application, []},
      extra_applications: [:logger, :runtime_tools, :edeliver]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.13"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.1"},
      {:bcrypt_elixir, "~> 2.0"},
      {:secure_random, "~> 0.5.1"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:hammer, "~> 6.0"},
      {:mogrify, "~> 0.7.3"},
      {:link_preview, git: "https://github.com/PabloG6/link_preview.git"},
      {:plug_cowboy, "~> 2.0"},
      {:guardian, "~> 2.0"},
      {:poison, "~> 4.0"},
      {:ecto_enum, "~> 1.4.0"},
      {:size, "~> 0.1.0"},
      {:edeliver, ">= 1.6.0"},
      {:distillery, "~> 2.0", warn_missing: false},
      {:corsica, "~> 1.1.3"},
      {:cors_plug, "~> 2.0"},
      {:recase, "~> 0.5"},

      {:stripity_stripe,
       git: "https://github.com/PabloG6/stripity_stripe",
       ref: "afe4c3e771e5627a97e361190b45d2d9b68ba9df"},
      {:todo, " >= 1.0.0", only: [:dev, :test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
