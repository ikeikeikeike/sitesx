use Mix.Config

config :sitesx,
  otp_app: MyApp,
  domain: "example.com",
  ensure_domain_interval: 0,
  dns: [
    provider: :cloudflare,
    auth_email: "mail@example.com",
    auth_key: "hash_key1",
    zone_identifier: "hash_key2",
  ]
  # request_options: [ssl: [{:versions, [:"tlsv1.2"]}]],
  # dns: [provider: :digitalocean]
