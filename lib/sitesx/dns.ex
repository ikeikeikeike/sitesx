defmodule Sitesx.DNS do
  @moduledoc """
  DNS adapter and behaviour.

  ## Example

      use Sitesx.DNS

  then must be implemented create_subdomain
  """

  alias HTTPoison.{Response, AsyncResponse}

  @doc """
  Create subdomain if not exists.

  ## Example

      dns = Sitesx.App.dns
      dns.create_subdomain "www"
  """
  @callback create_subdomain(subdomain::String.t, domain::String.t) ::
    {:ok, Response.t | AsyncResponse.t} |
    {:error, Error.t}

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      import PublicSuffix
      import Chexes, only: [present?: 1, blank?: 1]

      alias Sitesx.App

      @doc """
      Extract domain from hostname

      ## Example

          dns = Sitesx.App.dns
          dns.extract_domain "www.example.com"
          #-> "example"
      """
      @spec extract_domain(String.t) :: String.t | nil
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

          dns = Sitesx.App.dns
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

          dns = Sitesx.App.dns
          dns.ensured_subdomain? "www"
          #-> false
      """
      @spec ensured_subdomain?(String.t) :: boolean
      def ensured_subdomain?(subdomain) do
        ensured_domain? "#{subdomain}.#{App.domain}"
      end

      @doc """
      Make sure dns record using nslookup.

      ## Example

          dns = Sitesx.App.dns
          dns.ensured_domain? "www.example.com"
          #-> ture
      """
      @spec ensured_domain?(String.t) :: boolean
      def ensured_domain?(host) do
        case :inet_res.nslookup('#{host}', 1, :a) do
          {:ok, _}    -> true
          {:error, _} -> false
        end
      end
    end
  end
end
