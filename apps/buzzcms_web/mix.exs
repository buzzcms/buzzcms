defmodule BuzzcmsWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :buzzcms_web,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {BuzzcmsWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:phoenix, "~> 1.4.11"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:gettext, "~> 0.11"},
      {:buzzcms, in_umbrella: true},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:cors_plug, "~> 2.0"},
      {:absinthe, "~> 1.5.0-rc.2"},
      {:absinthe_plug, "~> 1.5.0-rc.1"},
      {:absinthe_relay, "~> 1.5.0-rc.0"},
      {:dataloader, "~> 1.0"},
      {:proper_case, "~> 1.3"},
      {:ex_image_info, "~> 0.2.4"},
      {:exconstructor, "~> 1.1"},
      {:nanoid, "~> 2.0"},
      {:httpoison, "~> 1.6"},
      {:ueberauth, "~> 0.6"},
      {:ueberauth_identity, "~> 0.2"},
      {:ueberauth_facebook, "~> 0.8"},
      {:guardian, "~> 2.0"},
      {:bamboo, "~> 1.4"},
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_machina, "~> 2.3", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, we extend the test task to create and migrate the database.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [test: ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
