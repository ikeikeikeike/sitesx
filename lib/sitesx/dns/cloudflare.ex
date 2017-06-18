defmodule Sitesx.DNS.Cloudflare do
  @moduledoc """
  Implementats domain behavior for Cloudflare DNS API

  ## Example

      iex(1)> Sitesx.Domain.
      Base                    create_subdomain/1      create_subdomain/2
      ensured_domain?/1       ensured_subdomain?/1    extract_domain/1
      extract_subdomain/1
      iex(1)> Sitesx.Domain.create_subdomain "subdomain-name"
      {:ok, result}
  """
  @behaviour Sitesx.DNS

  import Chexes, only: [blank?: 1]

  alias __MODULE__.API

  @doc """
  Create subdomain if not exists through the Cloudflare DNS API

  ## Example

      Sitesx.Domain.create_subdomain "subdomain-name"
  """
  @spec create_subdomain(subdomain::String.t, domain::String.t) ::
    {:ok, Response.t | AsyncResponse.t | term} |
    {:error, Error.t}
  def create_subdomain(subdomain, params \\ []) do
    case API.list_dns_records(params) do
      {:ok, %{body: %{"success" => true, "result" => records}}} ->
        if blank? Enum.filter(records, &String.starts_with?(&1["name"], "#{subdomain}.")) do
          API.create_dns_record name: subdomain
        else
          {:error, "duplicated subdomain"}
        end

      {:ok, %{body: %{"success" => false, "errors" => errors}}} ->
        {:error, errors}

      unknown ->
        {:error, unknown}
    end
  end

  defmodule API do
    @moduledoc """
    `list_dns_records`, `create_dns_record` functions.

    - List: https://api.cloudflare.com/#dns-records-for-a-zone-list-dns-records
    - Create: https://api.cloudflare.com/#dns-records-for-a-zone-create-dns-record
    """
    use HTTPoison.Base

    @endpoint "https://api.cloudflare.com/client/v4"

    def process_url(path) do
      Path.join @endpoint, path
    end

    def process_request_body(body) do
      case body do
        {:form, form} ->
          {:form, transform(form)}
        body ->
          body
      end
    end

    def process_request_options(options) do
      Application.get_env(:sitesx, :request_options) || [ssl: [{:versions, [:"tlsv1.2"]}]]
      |> Keyword.merge([recv_timeout: 10_000, timeout: 10_000])
      |> Keyword.merge(options)
    end

    def process_request_headers(headers) when is_map(headers) do
      process_request_headers Enum.into(headers, [])
    end

    def process_request_headers(headers) do
      overwrite = [
        "X-Auth-Email": dns_env(:auth_email),
        "X-Auth-Key": dns_env(:auth_key),
        "Content-Type": "application/json"
      ]
      Keyword.merge headers, overwrite
    end

    def process_response_body(body) do
      case Poison.decode body do
        {:ok,    body}        -> body
        {:error, body}        -> body
        {:error, :invalid, 0} -> body
      end
    end

    defp transform(payload) do
      for {k, v} <- payload, into: [], do: {:"#{k}", v}
    end

    defp dns_env(key) do
      parse_env Application.get_env(:sitesx, :dns)[key]
    end
    defp parse_env({:system, env}) when is_binary(env) do
      System.get_env(env) || ""
    end
    defp parse_env(env) do
      env
    end

    @doc """
    GET zones/:zone_identifier/dns_records
    """
    def list_dns_records(params \\ []) do
      params        = transform params
      {zid, params} = Keyword.pop params, :zone_identifier

      params =
        Keyword.merge(params, [
          page: 1, per_page: 100,  # TODO: over one hundred.
          order: "type",
          direction: "asc",
        ])

      get "/zones/#{zid || dns_env(:zone_identifier)}/dns_records", [], params:  params
    end

    @doc """
    POST zones/:zone_identifier/dns_records
    """
    def create_dns_record(params) do
      params           = transform params
      {zid, params}    = Keyword.pop params, :zone_identifier
      {name, params}   = Keyword.pop params, :name
      {domain, params} = Keyword.pop params, :domain, Application.get_env(:sitesx, :domain)

      params =
        Keyword.merge(params, [
          type: "CNAME",
          name: "#{name}.#{domain}",
          content: domain,
          proxied: true,
        ])

      body = Poison.encode! Enum.into(params, %{})
      post "/zones/#{zid || dns_env(:zone_identifier)}/dns_records", body
    end
  end
end
