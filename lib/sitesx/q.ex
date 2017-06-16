defmodule Sitesx.Q do
  @moduledoc """
  Ecto Query Helper
  """
  import Ecto.Query

  @before_compile Sitesx.Config

  def findsite(conn) do
    if name = sitesx_dns().extract_subdomain(conn) do
      from q in sitesx_site(),
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
    |> sitesx_repo().all
    |> case do
      [] -> false
      _  -> true
    end
  end

  def get_or_create(subdomain, domain \\ nil) do
    site = sitesx_site()
    repo = sitesx_repo()

    queryable =
      from q in site,
        where: q.name == ^subdomain,
        limit: 1

    if exists?(queryable) do
      {:get, repo.one(queryable)}
    else
      args      = [struct(site), %{"name" => subdomain}]
      changeset = apply site, :changeset, args

      new = repo.insert! changeset
      sitesx_dns().create_subdomain subdomain, domain

      {:new, new}
    end
  end

end
