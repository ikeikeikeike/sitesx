defmodule Sitesx.Support.ModelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Sitesx.Support.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import Sitesx.Support.ModelCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Sitesx.Support.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Sitesx.Support.Repo, {:shared, self()})
    end

    :ok
  end
end
