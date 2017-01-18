defmodule Sitesx.Config do
  @doc false
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      app    = Application.get_env(:sitesx, :app)
      domain = Application.get_env(:sitesx, :domain)

      @app app
      def app, do: @app

      @domain domain
      def domain, do: @domain
    end
  end
end
