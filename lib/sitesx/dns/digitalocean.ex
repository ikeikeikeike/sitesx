defmodule Sitesx.DNS.Digitalocean do
  @moduledoc """
  Uses DigitalOcean API
  """
  use Sitesx.DNS

  alias Oceanex.Resource.DomainRecord

  def create_subdomain(subdomain, params \\ []) do
    {domain, _} = Keyword.pop params, :domain, sitesx_domain()

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
