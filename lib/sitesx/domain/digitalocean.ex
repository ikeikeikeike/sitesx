defmodule Sitesx.Domain.Digitalocean do
  @moduledoc """
  Uses DigitalOcean API
  """
  use Sitesx.Domain

  alias Oceanex.Resource.DomainRecord

  require Logger

  def create_subdomain(subdomain, domain \\ nil) do
    domain = domain || xdomain()

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
        {:error, "#{domain}: #{reason}"}

      unknown ->
        Logger.error inspect(unknown)
        {:error, "unknown error"}
    end
  end

end
