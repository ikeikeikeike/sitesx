defmodule Sitesx.Domain do
  alias HTTPoison.{Response, AsyncResponse}

  @callback create_subdomain(subdomain::String.t, domain::String.t) :: {:ok, Response.t | AsyncResponse.t}
                                                                     | {:error, Error.t}

  defmacro __using__(_) do
    quote do
      @behaviour __MODULE__
      @before_compile Sitesx.Config

      import PublicSuffix
      import Chexes, only: [present?: 1]

      def extract_domain(host) do
        host
        |> String.downcase
        |> registrable_domain(ignore_private: true)
        |> String.split(".")
        |> List.first
      end

      def extract_subdomain(conn) do
        domain = "#{registrable_domain(conn.host)}"
        prefix = String.replace conn.host, ~r/#{domain}|\./, ""
        qstr   = conn.params["sub"]

        cond do
          prefix != ""   -> prefix
          present?(qstr) -> qstr
          true           -> nil
        end
      end

      def ensured_subdomain?(subdomain) do
        ensured_domain? "#{subdomain}.#{xdomain()}"
      end

      def ensured_domain?(host) do
        case :inet_res.nslookup('#{host}', 1, :a) do
          {:ok, _}    -> true
          {:error, _} -> false
        end
      end
    end
  end
end
