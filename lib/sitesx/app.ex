defmodule Sitesx.App do
  @moduledoc """
  Configuration from mix config and environment variable.

  Search document from the data store matching the given query.

  ## Options

    * `:ensure_domain_interval` - default: `0 secs (disabled)`
    * `:request_options` - default: `[ssl: [{:versions, [:"tlsv1.2"]}]]`

  ## Mix: Cloudflare

      config :sitesx,
        otp_app: MyApp,
        domain: "example.com",
        ensure_domain_interval: 300,
        dns: [
          provider: :cloudflare,
          auth_email: "mail@example.com",
          auth_key: "hash-key1",
          zone_identifier: "hash-key1",
        ]

  ## Mix: Digitalocean

      config :sitesx,
        otp_app: MyApp,
        domain: "example.com",
        request_options: [hackney: [pool: :cloudflare]],
        dns: :digitalocean

  """

  @before_compile __MODULE__.Base

  defmodule Base do
    @moduledoc false

    @doc false
    defmacro __using__(_opts) do
      quote do
        @before_compile unquote(__MODULE__)
      end
    end

    defmacro __before_compile__(_env) do
      quote do
        @app Application.get_env(:sitesx, :otp_app)
        @domain Application.get_env(:sitesx, :domain)

        @doc """
        domain function returns domain name
        """
        def domain,  do: @domain

        @doc """
        helper function returns view heloper like Phoenix and Plug
        """
        def helpers, do: Module.concat @app, Router.Helpers

        @doc """
        Ecto
        """
        def repo,    do: Module.concat @app, Repo

        @doc """
        repo function returns Sitesx model from your phoenix application.
        """
        def site,    do: Module.concat @app, Site
      end
    end
  end
end
