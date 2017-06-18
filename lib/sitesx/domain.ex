defmodule Sitesx.Domain do
  @moduledoc """
  `Sitesx.Domain` manages DNS record which has `detect`, `extract`, `create` method.
  """
  import PublicSuffix
  import Chexes, only: [present?: 1]

  alias Sitesx.App

  @doc """
  Extract domain from hostname

  ## Example

      Sitesx.Domain.extract_domain "www.example.com"
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

      Sitesx.Domain.extract_domain conn
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

      Sitesx.Domain.ensured_subdomain? "www"
      #-> false
  """
  @spec ensured_subdomain?(String.t) :: boolean
  def ensured_subdomain?(subdomain) do
    ensured_domain? "#{subdomain}.#{App.domain}"
  end

  @doc """
  Make sure dns record using nslookup.

  ## Example

      Sitesx.Domain.ensured_domain? "www.example.com"
      #-> ture
  """
  @spec ensured_domain?(String.t) :: boolean
  def ensured_domain?(host) do
    case :inet_res.nslookup('#{host}', 1, :a) do
      {:ok, _}    -> true
      {:error, _} -> false
    end
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
        dns = Application.get_env(:sitesx, :dns) || []
        case dns[:provider] || dns do
          :digitalocean ->
            @doc """
            See `Sitesx.DNS`
            """
            defdelegate create_subdomain(subdomain, params \\ []),
              to: Sitesx.DNS.Digitalocean

          :cloudflare when not is_binary(dns) ->
            @doc """
            See `Sitesx.DNS`
            """
            defdelegate create_subdomain(subdomain, params \\ []),
              to: Sitesx.DNS.Cloudflare

          _ ->
            raise ArgumentError,
              "In :sitesx :provider was missing " <>
              "configuration that value is `#{inspect dns}`"
        end
      end
    end
  end
end
