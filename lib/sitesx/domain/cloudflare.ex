defmodule Sitesx.Domain.Cloudflare do
  @moduledoc """
  Implementats domain behavior
  """
  use Sitesx.Domain

  defmodule API do
    @moduledoc """
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

    # @base_http_options [ssl: [{:versions, [:"tlsv1.2"]}]]
    # defp parse_http_options(:ssl) do
      # Keyword.merge @base_http_options, Config.get.http_client_options
    # end

    def process_request_options(options) do
      Keyword.merge [recv_timeout: 10_000, timeout: 10_000], options
    end

    def process_request_headers(headers) when is_map(headers) do
      process_request_headers Enum.into(headers, [])
    end

    def process_request_headers(headers) do
      overwrite = [
        "X-Auth-Email": "",
        "X-Auth-Key": "",
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

    @doc """
    GET zones/:zone_identifier/dns_records
    """
    def list_dns_records(params \\ []) do
      params =
        Keyword.merge(transform(params), [
          page: 1,
          per_page: 100,
          order: "type",
          direction: "asc",
        ])

      get "/zones/:zone_identifier/dns_records", [], params:  params
    end

    @doc """
    POST zones/:zone_identifier/dns_records
    """
    def create_dns_record(params) do
      post "/zones/:zone_identifier/dns_records", {:form, params}
    end
  end

end
