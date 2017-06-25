defmodule Sitesx.DNS.Digitalocean do
  @moduledoc false

  use Sitesx.DNS, endpoint: "https://api.digitalocean.com/v2"

  @doc false
  def create_subdomain(subdomain, params \\ []) do
    case dns_records params do
      {:ok, %{body: %{"domain_records" => records}}} ->
        if blank? Enum.filter(records, & &1["name"] == subdomain and &1["type"] == "CNAME") do
          create_dns_record name: subdomain
        else
          {:error, "duplicated subdomain"}
        end

      {:ok, %{body: %{"id" => reason}}} ->
        {:error, reason}

      unknown ->
        {:error, unknown}
    end
  end

  # TODO: Pagination
  @doc false
  def dns_records(params \\ []) do
    params        = transform params
    {domain, params} = Keyword.pop params, :domain, Application.get_env(:sitesx, :domain)

    get "/domains/#{domain}/records", [], params:  params
  end

  @doc false
  def create_dns_record(params) do
    params           = transform params
    {name, params}   = Keyword.pop params, :name
    {domain, params} = Keyword.pop params, :domain, Application.get_env(:sitesx, :domain)

    params =
      Keyword.merge(params, [
        type: "CNAME",
        name: name,
        data: "#{domain}.",
      ])

    body = Poison.encode! Enum.into(params, %{})
    post "/domains/#{domain}/records", body
  end

  @doc false
  def process_request_headers(headers) do
    overwrite = [
      "Authorization": "Bearer #{dns_env(:auth_key)}"
    ]

    Keyword.merge super(headers), overwrite
  end

end
