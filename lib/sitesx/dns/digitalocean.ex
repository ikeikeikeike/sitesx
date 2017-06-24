defmodule Sitesx.DNS.Digitalocean do
  @moduledoc false

  use Sitesx.DNS, endpoint: "https://api.digitalocean.com/v2"
  alias Sitesx.App

  @doc false
  def create_subdomain(subdomain, params \\ []) do
    {domain, _} = Keyword.pop params, :domain, App.domain

    case dns_records(domain) do
      {:ok, %{body: %{domain_records: records}}} ->
        if blank? Enum.filter(records, & &1[:name] == domain) do
          record =
            records
            |> Enum.filter(& &1[:name] == "@")
            |> Enum.filter(& &1[:type] == "A")
            |> List.first
            |> Kernel.||(%{})
            |> Map.delete(:id)
            |> Map.merge(%{name: subdomain})

          DomainRecord.create_dns_record domain, record
        else
          {:error, "duplicated subdomain"}
        end

      {:ok, %{body: %{id: reason}}} ->
        {:error, reason}

      unknown ->
        {:error, unknown}
    end
  end

  @doc false
  def dns_records(params \\ []) do
    params        = transform params
    {domain, params} = Keyword.pop params, :domain, Application.get_env(:sitesx, :domain)

    params =
      Keyword.merge(params, [
        page: 1, per_page: 100,
        order: "type",
        direction: "asc",
      ])

    get "/v2/domains/#{domain}/records", [], params:  params
  end

  @doc false
  def create_dns_record(params) do
    params           = transform params
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
    post "/v2/domains/#{domain}/records", body
  end

  @doc false
  def process_request_headers(headers) do
    overwrite = [
      "Authorization": "Bearer #{dns_env(:auth_key)}"
    ]

    Keyword.merge super(headers), overwrite
  end

end
