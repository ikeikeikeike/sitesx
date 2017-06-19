defmodule Sitesx.Support.Endpoint do
  use Phoenix.Endpoint, otp_app: :sitesx

  plug Plug.Static,
    at: "/", from: :sitesx, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt prepare)

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_sitesx_key",
    signing_salt: "7sp/ClfG"

  plug Sitesx.Support.Router
end
