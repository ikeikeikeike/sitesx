defmodule Sitesx.DNS do
  @moduledoc """
  DNS adapter and behaviour.

  ## Example

      use Sitesx.DNS
  """

  alias HTTPoison.{Response, AsyncResponse}

  @callback create_subdomain(subdomain::String.t, domain::String.t) :: {:ok, Response.t | AsyncResponse.t}
                                                                     | {:error, Error.t}

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      import PublicSuffix
      import Chexes, only: [present?: 1, blank?: 1]

      alias Sitesx.Config

      @doc """
      Extract domain from hostname

      ## Example

          dns = Sitesx.Config.dns
          dns.extract_domain "www.example.com"
          #-> "example"
      """
      def extract_domain(host) do
        host
        |> String.downcase
        |> registrable_domain(ignore_private: true)
        |> String.split(".")
        |> List.first
      end

      @doc """
      Extract subdomain from `Plug.Conn`

      ## Example

          dns = Sitesx.Config.dns
          dns.extract_domain conn
          #-> "www"
      """
      @spec extract_subdomain(Plug.Conn.t) :: boolean | String.t
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

      @doc """
      Make sure subdomain using nslookup.

      ## Example

          dns = Sitesx.Config.dns
          dns.ensured_subdomain? "www"
          #-> false
      """
      def ensured_subdomain?(subdomain) do
        ensured_domain? "#{subdomain}.#{Config.domain}"
      end

      @doc """
      Make sure dns record using nslookup.

      ## Example

          dns = Sitesx.Config.dns
          dns.ensured_domain? "www.example.com"
          #-> ture
      """
      def ensured_domain?(host) do
        case :inet_res.nslookup('#{host}', 1, :a) do
          {:ok, _}    -> true
          {:error, _} -> false
        end
      end
    end
  end
end
