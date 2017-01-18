defmodule Sitesx.Q do
  import Ecto.Query

  alias Sitesx.Domain

  @app Application.get_env(:sitesx, :app)

  def findsite(conn) do
    case Domain.extract_subdomain(conn) do
      nil  -> nil
      name ->
        from q in @app.Site,
          where: q.name == ^name
    end
  end

  def with_site(queryable, conn) do
    if site = conn.private.sitesx_model do
      from q in queryable, where: q.site_id == ^(site.id)
    else
      queryable
    end
  end

end
