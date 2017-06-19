use Mix.Config

config :sitesx,
  otp_app: Sitesx.Support,
  domain: "example.com",
  ensure_domain_interval: 0,
  # request_options: [ssl: [{:versions, [:"tlsv1.2"]}]],
  # dns: [provider: :digitalocean]
  dns: [
    provider: :cloudflare,
    auth_email: "mail@example.com",
    auth_key: "hash_key1",
    zone_identifier: "hash_key2",
  ]

config :sitesx,
  :ecto_repos, [Sitesx.Support.Repo]

# Configures the endpoint
config :sitesx, Sitesx.Support.Endpoint,
  http: [port: 80],
  url: [host: "example.com"],
  secret_key_base: "sGGhsAODcN3CbgamO4wHDIwHoj2GV6leeMkI3XL+ROBryXWhP7iIAlqbHBR1GGLx",
  server: false

config :sitesx, Sitesx.Support.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "sitesx_test",
  username: "postgres",
  password: "postgres",
  hostname: "127.0.0.1",
  pool: Ecto.Adapters.SQL.Sandbox,
  timeout: 60_000,
  pool_timeout: 60_000,
  ownership_timeout: 60_000

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
config :logger, level: :warn
