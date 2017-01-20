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

      def cfg_app, do: @app
      def cfg_domain, do: @domain

      def concat(module) do
        Module.concat cfg_app(), module
      end
    end
  end
end
