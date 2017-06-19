{:ok, _pid} = Sitesx.Support.Repo.start_link
Ecto.Adapters.SQL.Sandbox.mode(Sitesx.Support.Repo, {:shared, self()})

Sitesx.Support.Repo.insert!(%Sitesx.Support.Site{name: "subdomain1", dns: true})
Sitesx.Support.Repo.insert!(%Sitesx.Support.Site{name: "subdomain2", dns: false})
Sitesx.Support.Repo.insert!(%Sitesx.Support.Site{name: "subdomain3", dns: true})
Sitesx.Support.Repo.insert!(%Sitesx.Support.Site{name: "subdomain4", dns: false})
