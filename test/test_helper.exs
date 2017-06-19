ExUnit.start

{:ok, _pid} = Sitesx.Support.Endpoint.start_link
{:ok, _pid} = Sitesx.Support.Repo.start_link
Ecto.Adapters.SQL.Sandbox.mode(Sitesx.Support.Repo, {:shared, self()})
