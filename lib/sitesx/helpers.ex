defmodule Sitesx.Helpers do
  alias Phoenix.HTML.SimplifiedHelpers.URL

  @before_compile Sitesx.Config

  def subdomain_url(conn, ctrl_act_param, opts \\ [])

  def subdomain_url(%Plug.Conn{} = conn, ctrl_act_param, opts) do
    case Sitesx.Domain.extract_subdomain(conn) do
      nil       -> URL.url_for conn, ctrl_act_param, opts
      subdomain -> subdomain_url subdomain, conn, ctrl_act_param, opts
    end
  end

  def subdomain_url(subdomain, conn, ctrl_act_param)
      when is_binary(subdomain) or is_atom(subdomain) do
    subdomain_url subdomain, conn, ctrl_act_param, []
  end

  def subdomain_url(subdomain, conn, ctrl_act_param, opts) do
    base = URI.parse @app.Router.Helpers.url(conn)
    path = URL.url_for conn, ctrl_act_param, opts
    u    = URI.merge base, path

    key  = "subdomain_url:#{subdomain}:#{to_string(u)}:true"
    ConCache.get_or_store :sitesx, key, fn ->
      @app.Site
      |> @app.Repo.get_by(name: subdomain, dns: true)
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
