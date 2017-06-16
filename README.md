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
defmodule MyApp.Sitesx do
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

Mix commands `mix sitesx.gen.model` or `mix sitesx.gen.schema` will be able to generate No.3 and No.4 instead of define manually.


```shell
$ mix sitesx.gen.model   # Until phoenix v1.2.x
$ mix sitesx.gen.schema  # Phoenix v1.3.x
```


## Customization

Supposedly, those definition are still not enough to work on development. Therefore it will be changed is better that have `1:N` relation between one of a model and `Sitesx` model.

```elixir
defmodule MyApp.Entry do
  use MyApp.Web, :model

  schema "entries" do
    belongs_to :sitesx, MyApp.Sitesx
    field :title, :string
    field :content, :string

    timestamps()
  end
end
```

and

```elixir
defmodule MyApp.Sitesx do
  use MyApp.Web, :model

  schema "sitesx" do
    has_many :entries, MyApp.Entry
    field :name, :string
    field :dns, :boolean

    timestamps()
  end
end
```
