defmodule Sitesx.Q do
  import Ecto.Query
  alias Sitesx.Domain

  @before_compile Sitesx.Config

  def findsite(conn) do
    case Domain.extract_subdomain(conn) do
      nil  -> nil
      name ->
        from q in xsite(),
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

  def exists?(queryable) do
    queryable
    |> from(select: 1, limit: 1)
    |> xrepo().all
    |> case do
      [] -> false
      _  -> true
    end
  end

  def get_or_create(subdomain, domain \\ nil) do
    site = xsite()
    repo = xrepo()

    queryable =
      from q in site,
        where: q.name == ^subdomain,
        limit: 1

    unless exists?(queryable) do
      args      = [struct(site), %{"name" => subdomain}]
      changeset = apply site, :changeset, args

      repo.insert! changeset
      Domain.create_subdomain subdomain, domain

      {:new, site}
    else
      {:get, repo.one(queryable)}
    end
  end

end
