# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :buzzcms,
  ecto_repos: [Buzzcms.Repo]

config :buzzcms, Buzzcms.Repo, types: Buzzcms.PostgresTypes

config :buzzcms_web,
  ecto_repos: [Buzzcms.Repo],
  generators: [context_app: :buzzcms]

# Configures the endpoint
config :buzzcms_web, BuzzcmsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "c5A4s9xzmEJpYad2/7mfSuuMw34xb2Pf+m5T2zP901yIhm4RH9GFmZbbeORR09mz",
  render_errors: [view: BuzzcmsWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: BuzzcmsWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  json_library: Jason,
  providers: [
    identity: {Ueberauth.Strategy.Identity, [callback_methods: ["POST"]]},
    facebook: {Ueberauth.Strategy.Facebook, []}
  ]

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: "1690946351207352",
  client_secret: "0a7a5bc1f09fa8f0a71cfb1630e8bf3b"

config :buzzcms_web, BuzzcmsWeb.Auth.Guardian,
  issuer: "buzzcms",
  secret_key: "eyybqzMu3LJRYHGjKBl+GevxnGaXqjzZomabh9ax7zt5spp0rgYKWnPX4dSNN/8r"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
