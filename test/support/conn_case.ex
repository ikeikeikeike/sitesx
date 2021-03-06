defmodule Sitesx.Support.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest

      alias Sitesx.Support.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import Sitesx.Support.Router.Helpers

      @endpoint Sitesx.Support.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Sitesx.Support.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Sitesx.Support.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
