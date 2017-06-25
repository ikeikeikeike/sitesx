defmodule Sitesx.DNS do
  @moduledoc """
  DNS adapter and behaviour.

  ## Example

      use Sitesx.DNS

  Then must be implemented `create_subdomain`, `dns_records`, `create_dns_record` functions.

  Now Sitesx has `Sitesx.DNS.Digitalocean`, `Sitesx.DNS.Cloudflare` DNS modules.

  ## Implementats domain behavior for Digitalocean DNS API

  ### Create subdomain if not exists through the Digitalocean DNS API

      Sitesx.Domain.create_subdomain "subdomain-name"

  ### Get dns records

      Sitesx.Domain.dns_records

  #### Options

    * `:domain` - default: extract from mix config

  `GET /v2/domains/$DOMAIN_NAME/records`

  [Documentation](https://developers.digitalocean.com/documentation/v2/#list-all-domain-records)

  ### Create a dns record

      Sitesx.Domain.create_dns_record name: "wwww"

  #### Options

    * `:name`   - require: subdomain name
    * `:domain` - default: extract from mix config

  `POST /v2/domains/$DOMAIN_NAME/records`

  [Documentation](https://developers.digitalocean.com/documentation/v2/#create-a-new-domain-record)

  ## Implementats domain behavior for Cloudflare DNS API

  ### Create subdomain if not exists through the Cloudflare DNS API

      Sitesx.Domain.create_subdomain "subdomain-name"

  ### Get dns records

      Sitesx.Domain.dns_records

  #### Options

    * `:domain` - default: extract from mix config

  `GET zones/:zone_identifier/dns_records`

  ### Create a dns record

      Sitesx.Domain.create_dns_record name: "wwww"

  #### Options

    * `:name`   - require: subdomain name
    * `:domain` - default: extract from mix config

  `POST zones/:zone_identifier/dns_records`

  [Documentation](https://api.cloudflare.com/#dns-records-for-a-zone-create-dns-record)

  """
  alias HTTPoison.{Response, AsyncResponse}

  @doc """
  Create subdomain if not exists.

  ## Example

      Sitesx.Domain.create_subdomain "www"
  """
  @callback create_subdomain(subdomain::String.t, params::list) ::
    {:ok, Response.t | AsyncResponse.t | term} |
    {:error, Error.t}

  @doc """
  Create subdomain if not exists.

  ## Example

      Sitesx.Domain.dns_records
  """
  @callback dns_records(params::list) ::
    {:ok, Response.t | AsyncResponse.t | term} |
    {:error, Error.t}

  @doc """
  Create a dns record

  ## Example

      Sitesx.Domain.create_dns_record name: "www"
  """
  @callback create_dns_record(params::list) ::
    {:ok, Response.t | AsyncResponse.t | term} |
    {:error, Error.t}


  @doc false
  defmacro __using__(opts) do
    quote do
      use HTTPoison.Base

      import Chexes
      alias Sitesx.App

      @behaviour unquote(__MODULE__)
      @endpoint  unquote(opts[:endpoint])

      @doc false
      def endpoint do
        @endpoint
      end

      @doc false
      def process_url(path) do
        Path.join @endpoint, path
      end

      @doc false
      def process_request_body(body) do
        case body do
          {:form, form} ->
            {:form, transform(form)}
          body ->
            body
        end
      end

      @doc false
      def process_request_options(options) do
        Application.get_env(:sitesx, :request_options) || [ssl: [{:versions, [:"tlsv1.2"]}]]
        |> Keyword.merge([recv_timeout: 10_000, timeout: 10_000])
        |> Keyword.merge(options)
      end

      @doc false
      def process_request_headers(headers) when is_map(headers) do
        process_request_headers Enum.into(headers, [])
      end

      @doc false
      def process_request_headers(headers) do
        overwrite = ["Content-Type": "application/json"]
        Keyword.merge headers, overwrite
      end

      @doc false
      def process_response_body(body) do
        case Poison.decode body do
          {:ok,    body}        -> body
          {:error, body}        -> body
          {:error, :invalid, 0} -> body
        end
      end

      @doc false
      defp transform(payload) do
        for {k, v} <- payload, into: [], do: {:"#{k}", v}
      end

      @doc false
      defp dns_env(key) do
        App.parse_env Application.get_env(:sitesx, :dns)[key]
      end

      defoverridable [
        process_url: 1,
        process_request_options: 1,
        process_request_headers: 1,
        process_response_body: 1,
      ]

    end
  end
end
