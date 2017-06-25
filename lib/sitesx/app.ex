defmodule Sitesx.App do
  @moduledoc """
  Configuration from mix config and environment variable.

  ## Options

    * `:ensure_domain_interval` - default: `600_000 millisecond (if want disable, set 0 number)`
    * `:request_options` - default: `[ssl: [{:versions, [:"tlsv1.2"]}]]`

  ## Mix: Cloudflare

      config :sitesx,
        otp_app: MyApp,
        domain: "example.com",
        ensure_domain_interval: 300_000,
        dns: [
          provider: :cloudflare,
          auth_email: "mail@example.com",
          auth_key: "1234567893feefc5f0q5000bfo0c38d90bbeb",
          zone_identifier: "3d9313b646b8cc1ieb5b4c73a9aae20c",
        ]

  ## Mix: Digitalocean

      config :sitesx,
        otp_app: MyApp,
        domain: "example.com",
        request_options: [hackney: [pool: :cloudflare]],
        dns: [
          provider: :digitalocean,
          auth_key: "b7d03a6947b217efb6f3ec3bd3504582",
        ]

  ## Environment Variable: Cloudflare

      config :sitesx,
        otp_app: MyApp,
        domain: "example.com",
        ensure_domain_interval: 300_000,
        dns: [
          provider: :cloudflare,
          auth_email: {:system, "MYAPP_AUTH_EMAIL"},
          auth_key: {:system, "MYAPP_AUTH_KEY"},
          zone_identifier: {:system, "MYAPP_ZONE_IDENTIFIER"},
        ]

  ## Environment Variable: Digitalocean

      config :sitesx,
        otp_app: MyApp,
        domain: "example.com",
        ensure_domain_interval: 300_000,
        dns: [
          provider: :cloudflare,
          auth_key: {:system, "MYAPP_AUTH_KEY"},
        ]

  """

  def parse_env({:system, env}) when is_binary(env) do
    System.get_env(env) || ""
  end
  def parse_env(env) do
    env
  end

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
        alias Sitesx.App

        @app Application.get_env(:sitesx, :otp_app)

        @doc """
        domain function returns domain name
        """
        def domain,  do: App.parse_env Application.get_env(:sitesx, :domain)

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
