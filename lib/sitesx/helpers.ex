defmodule Sitesx.Helpers do
  @moduledoc """
  Generate URL with subdomain for controller or templates
  along with `Phoenix.HTML.SimplifiedHelpers.URL`

  ## Example

      subdomain_url(@conn, "entry.latest")
      #-> http://subdomain1.example.com/entries/latest

      subdomain_url("www", @conn, "page.index")
      #-> http://www.example.com/entries/latest

  A conn variable contains sitesx struct(model) which has domain information
  through a `Sitesx.Plug` module that extracted from request URL or `sub` queryparameter.

  """
  alias Sitesx.{App, Domain}
  alias Phoenix.HTML.SimplifiedHelpers.URL

  def subdomain_url(conn, ctrl_act_param, opts \\ [])

  @doc """
  Generate URL from `Plug.Conn` struct

  ## Call function with ensured DNS record.

      subdomain_url(@conn, "entry.latest")
      #-> http://subdomain1.example.com/entries/latest

  ## Call function with not ensured DNS record.

      subdomain_url(@conn, "entry.latest")
      #-> http://example.com/entries/latest?sub=subdomain1
  """
  @spec subdomain_url(conn::Plug.Conn.t, ctrl_act_param::String.t, opts::list) :: String.t
  def subdomain_url(%Plug.Conn{} = conn, ctrl_act_param, opts) do
    case Domain.extract_subdomain(conn) do
      nil       -> URL.url_for conn, ctrl_act_param, opts
      subdomain -> subdomain_url subdomain, conn, ctrl_act_param, opts
    end
  end

  @doc """
  Generate URL from subdomain name

  ## Call function with ensured DNS record.

      subdomain_url("subdomain2", @conn, "entry.latest")
      #-> http://subdomain2.example.com/entries/latest

  ## Call function with not ensured DNS record.

      subdomain_url("subdomain2", @conn, "entry.latest")
      #-> http://example.com/entries/latest?sub=subdomain2

  """
  @spec subdomain_url(subdomain::String.t, conn::Plug.Conn.t, ctrl_act_param::String.t) :: String.t
  def subdomain_url(subdomain, conn, ctrl_act_param)
      when is_binary(subdomain) or is_atom(subdomain) do
    subdomain_url subdomain, conn, ctrl_act_param, []
  end

  @doc """
  Generate URL with querystring from subdomain name

  ## Call function with ensured DNS record.

      subdomain_url("subdomain2", @conn, "entry.latest", some: "query", unko: "query2")
      #-> http://subdomain2.example.com/entries/latest?some=query&unko=query2

  ## Call function with not ensured DNS record.

      subdomain_url("subdomain2", @conn, "entry.latest", some: "query", unko: "query2")
      #-> http://example.com/entries/latest?sub=subdomain2&some=query&unko=query2
  """
  @spec subdomain_url(subdomain::String.t, conn::Plug.Conn.t, ctrl_act_param::String.t, opts::list) :: String.t
  def subdomain_url(subdomain, conn, ctrl_act_param, opts) do
    base = URI.parse App.helpers().url(conn)
    path = URL.url_for conn, ctrl_act_param, opts
    u    = URI.merge base, path

    key  = "subdomain_url:#{subdomain}:#{to_string(u)}:true"
    ConCache.get_or_store :sitesx, key, fn ->
      App.site()
      |> App.repo().get_by(name: subdomain, dns: true)
      |> (case do
        nil ->
          query =
            (u.query || "")
            |> URI.decode_query(%{"sub" => subdomain})
            |> URI.encode_query

          %{u | query: query}

        _   ->
          %{u | host: "#{subdomain}.#{u.host}"}
      end)
      |> to_string
    end
  end

end
