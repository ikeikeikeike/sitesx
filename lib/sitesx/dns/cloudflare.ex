defmodule Sitesx.DNS.Cloudflare do
  @moduledoc false

  use Sitesx.DNS, endpoint: "https://api.cloudflare.com/client/v4"

  @doc false
  def create_subdomain(subdomain, params \\ []) do
    case dns_records(params) do
      {:ok, %{body: %{"success" => true, "result" => records}}} ->
        if blank? Enum.filter(records, &String.starts_with?(&1["name"], "#{subdomain}.")) do
          create_dns_record name: subdomain
        else
          {:error, "duplicated subdomain"}
        end

      {:ok, %{body: %{"success" => false, "errors" => errors}}} ->
        {:error, errors}

      unknown ->
        {:error, unknown}
    end
  end

  @doc false
  def dns_records(params \\ []) do
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

  @doc false
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

  @doc false
  def process_request_headers(headers) do
    overwrite = [
      "X-Auth-Email": dns_env(:auth_email),
      "X-Auth-Key": dns_env(:auth_key),
    ]

    Keyword.merge super(headers), overwrite
  end

end
