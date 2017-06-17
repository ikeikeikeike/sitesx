use Mix.Config

config :sitesx,
  otp_app: Yavd,             # OR     : Mix.Project.config[:app]
  domain: "example.com",
  ensure_domain_interval: 300,    # Default: 0 secs (disabled)
  # request_options: [ssl: [{:versions, [:"tlsv1.2"]}]],
  dns: [
    provider: :cloudflare,
    auth_email: "mail@example.com",
    auth_key: "hash_key1",
    zone_identifier: "hash_key2",
  ]
  # dns: [provider: :digitalocean]
