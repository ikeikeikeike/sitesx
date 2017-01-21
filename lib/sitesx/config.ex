defmodule Sitesx.Config do
  @doc false
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @app    Application.get_env(:sitesx, :otp_app)
      @domain Application.get_env(:sitesx, :domain)

      def xdomain,  do: @domain
      def xhelpers, do: Module.concat @app, Router.Helpers
      def xrepo,    do: Module.concat @app, Repo
      def xsite,    do: Module.concat @app, Site
    end
  end
end
