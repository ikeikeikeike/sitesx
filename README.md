# Sitesx

A Phoenix SubDomainer which makes subdomain using DigitalOcean, Cloudflare, etc. API and contains convenient view helper interface along with Plug and Ecto

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add `sitesx` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:sitesx, "~> 0.1.0"}]
end
```

2. Ensure `sitesx` is started before your application:

```elixir
def application do
  [applications: [:sitesx]]
end
```

3. Sitesx needs to add a migration:

```elixir
defmodule MyApp.Repo.Migrations.CreateSitesx do
  use Ecto.Migration

  def change do
    create table(:sitesx) do
      add :name, :string
      add :dns, :boolean, default: false

      timestamps()
    end
    create index(:sites, [:name], unique: true)
    create index(:sites, [:dns])

  end
end
```

4. After definition, needs to add a model:

```elixir
defmodule MyApp.Sitex do
  use MyApp.Web, :model

  schema "sitesx" do
    field :name, :string
    field :dns, :boolean

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name dns])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
```

Mix command.
