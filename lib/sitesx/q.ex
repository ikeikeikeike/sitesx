defmodule Sitesx.Q do
  @moduledoc """
  Ecto Query Helper
  """
  import Ecto.Query

  alias Sitesx.Config

  def findsite(conn) do
    if name = Config.dns().extract_subdomain(conn) do
      from q in Config.site(),
        where: q.name == ^name
    end
  end

  def with_site(queryable, conn) do
    if site = conn.private.sitesx.model do
      from q in queryable, where: q.site_id == ^(site.id)
    else
      queryable
    end
  end

  def exists?(queryable) do
    queryable
    |> from(select: 1, limit: 1)
    |> Config.repo().all
    |> case do
      [] -> false
      _  -> true
    end
  end

  def get_or_create(subdomain, domain \\ nil) do
    site = Config.site()
    repo = Config.repo()

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
      Config.dns().create_subdomain subdomain, domain

      {:new, new}
    end
  end

end
