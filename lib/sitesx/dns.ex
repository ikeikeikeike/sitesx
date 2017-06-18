defmodule Sitesx.DNS do
  @moduledoc """
  DNS adapter and behaviour.

  ## Example

      @behaviour Sitesx.DNS

  Then must be implemented create_subdomain function.

  Now Sitesx has `Sitesx.DNS.Digitalocean`, `Sitesx.DNS.Cloudflare` DNS modules.
  """

  alias HTTPoison.{Response, AsyncResponse}

  @doc """
  Create subdomain if not exists.

  ## Example

      Sitesx.Domain.create_subdomain "www"
  """
  @callback create_subdomain(subdomain::String.t, domain::String.t|list) ::
    {:ok, Response.t | AsyncResponse.t | term} |
    {:error, Error.t}
end
