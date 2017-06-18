defmodule Sitesx.DNS.Digitalocean do
  @moduledoc """
  Implementats domain behavior for Digitalocean DNS API

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

  alias Sitesx.App
  alias Oceanex.Resource.DomainRecord

  @doc """
  Create subdomain if not exists through the Digitalocean DNS API

  ## Example

      Sitesx.Domain.create_subdomain "subdomain-name"
  """
  @spec create_subdomain(subdomain::String.t, domain::String.t) ::
    {:ok, Response.t | AsyncResponse.t | term} |
    {:error, Error.t}
  def create_subdomain(subdomain, params \\ []) do
    {domain, _} = Keyword.pop params, :domain, App.domain

    case DomainRecord.all(domain) do
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

          DomainRecord.create domain, record
        else
          {:error, "duplicated subdomain"}
        end

      {:ok, %{body: %{id: reason}}} ->
        {:error, reason}

      unknown ->
        {:error, unknown}
    end
  end
end
