defmodule Sitesx.Q do
  @moduledoc """
  Ecto Query Helper along with Sitesx.Plug
  """
  import Ecto.Query

  alias Sitesx.{App, Domain}

  @doc """
  Find a record from `Plug.Conn` or subdomain name

  ## Example

      Sitesx.Q.findstate(conn)
      #-> %MyApp.Site{id: 1, name: "subdomain1", dns: true} or nil

      Sitesx.Q.findstate("subdomain1")
      #-> %MyApp.Site{id: 1, name: "subdomain1", dns: true} or nil
  """
  @spec findsite(conn::Plug.Conn.t) :: Ecto.Query.t | nil
  def findsite(%Plug.Conn{} = conn) do
    if name = Domain.extract_subdomain(conn) do
      from q in App.site(),
        where: q.name == ^name
    end
  end

  @spec findsite(name::String.t) :: Ecto.Query.t | nil
  def findsite(name) do
    from q in App.site(),
      where: q.name == ^name
  end

  @doc """
  Get a sitesx record from model which relates as 1:N between one of model and `Sitesx`

  ## Example

      defmodule MyApp.MyController do
        use MyApp.Web, :controller
        plug Sitesx.Plug

        def something(conn, params) do
          entries =
            Entry
            |> Sitesx.Q.with_site(conn)
            |> Repo.paginate(params)

          render conn, "something.html", entries: entries
        end
      end
  """
  @spec with_site(Ecto.Query.t, Plug.Conn.t) :: Ecto.Query.t
  def with_site(queryable, conn) do
    if site = conn.private.sitesx.model do
      from q in queryable, where: q.site_id == ^(site.id)
    else
      queryable
    end
  end

  @doc """
  Like a exists query statement.

  ## Example

      queryable =
        from q in MyApp.Site,
          where: q.name == "subdomain1",

      Sitesx.Q.exists?(queryable)
      #-> true


  """
  @spec exists?(Ecto.Query.t) :: boolean
  def exists?(queryable) do
    queryable
    |> from(select: 1, limit: 1)
    |> App.repo().all
    |> case do
      [] -> false
      _  -> true
    end
  end

  @doc """
  Get a record or create a record then returns a record with result key.

  ## Example

      case Sitesx.Q.get_or_create("subdomain1") do
        {:new, %MyApp.Site{} = site} ->
          dosomething(site)

        {:get, %MyApp.Site{} = site} ->
          site
      end
  """
  @spec get_or_create(Ecto.Query.t, String.t) :: {:get, term} | {:new, term}
  def get_or_create(subdomain, domain \\ nil) do
    site = App.site()
    repo = App.repo()

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
      Domain.create_subdomain subdomain, domain

      {:new, new}
    end
  end

  @doc """
  To ensure all of dns record, which stores boolean to database.
  """
  @spec ensure_domains :: :ok
  def ensure_domains do
    repo = App.repo

    Enum.each App.site, fn s ->
      bool = Domain.ensured_subdomain?(s.name)

      Ecto.Changeset.change(s, dns: bool)
      |> repo.update
    end
  end

end
