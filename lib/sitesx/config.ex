defmodule Sitesx.Config do
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
      dns = Application.get_env(:sitesx, :dns) || []
      @dns(case dns[:provider] || dns do
        :digitalocean ->
          Sitesx.Domain.Digitalocean

        :cloudflare when not is_binary(dns) ->
          Sitesx.Domain.Cloudflare

        _ ->
          raise ArgumentError,
            "In :sitesx :provider was missing " <>
            "configuration that value is `#{inspect dns}`"
      end)

      def sitesx_dns,     do: @dns
      def sitesx_domain,  do: @domain
      def sitesx_helpers, do: Module.concat @app, Router.Helpers
      def sitesx_repo,    do: Module.concat @app, Repo
      def sitesx_site,    do: Module.concat @app, Sitex
    end
  end
end
