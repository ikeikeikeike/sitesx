# Sitesx

[![Build Status](http://img.shields.io/travis/ikeikeikeike/sitesx.svg?style=flat-square)](http://travis-ci.org/ikeikeikeike/sitesx)
[![Ebert](https://ebertapp.io/github/ikeikeikeike/sitesx.svg)](https://ebertapp.io/github/ikeikeikeike/sitesx)
[![Hex version](https://img.shields.io/hexpm/v/sitesx.svg "Hex version")](https://hex.pm/packages/sitesx)
[![Inline docs](https://inch-ci.org/github/ikeikeikeike/sitesx.svg)](http://inch-ci.org/github/ikeikeikeike/sitesx)
[![Lisence](https://img.shields.io/hexpm/l/ltsv.svg)](https://github.com/ikeikeikeike/sitesx/blob/master/LICENSE)

A Phoenix SubDomainer which makes subdomain using DigitalOcean, Cloudflare, etc. API and contains convenient view helper interface along with Plug and Ecto

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add `sitesx` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:sitesx, "~> 0.10"}]
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
defmodule MyApp.Repo.Migrations.CreateSite do
  use Ecto.Migration

  def change do
    create table(:sites) do
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
defmodule MyApp.Site do
  use MyApp.Web, :model

  schema "sites" do
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

~~Mix commands `mix sitesx.gen.model` or `mix sitesx.gen.schema` will be able to generate No.3 and No.4 instead of define manually.~~

```shell
$ mix sitesx.gen.model   # Until phoenix v1.2.x
$ mix sitesx.gen.schema  # Phoenix v1.3.x
```

5. Configuration

`Cloudflare`

```elixir
config :sitesx,
  otp_app: MyApp,
  domain: "example.com",
  ensure_domain_interval: 300,
  dns: [
    provider: :cloudflare,
    auth_email: "mail@example.com",
    auth_key: "hash-key1",
    zone_identifier: "hash-key1",
  ]
```

`Digitalocean`

```elixir
config :sitesx,
  otp_app: MyApp,
  domain: "example.com",
  request_options: [hackney: [pool: :cloudflare]],
  dns: :digitalocean
```

###### `Sitesx.App`, Configuration from mix config and environment variable.

hexdocs: https://hexdocs.pm/sitesx/Sitesx.App.html

## Customization

Supposedly, those definition are still not enough to work on development. Therefore it will be changed is better that have `1:N` relation between one of a model and `Site` model.

```elixir
defmodule MyApp.Entry do
  use MyApp.Web, :model

  schema "entries" do
    belongs_to :site, MyApp.Site
    field :title, :string
    field :content, :string

    timestamps()
  end
end
```

and

```elixir
defmodule MyApp.Site do
  use MyApp.Web, :model

  schema "sites" do
    has_many :entries, MyApp.Entry
    field :name, :string
    field :dns, :boolean

    timestamps()
  end
end
```

## Usage

#### `Sitesx.Domain` manages DNS record which has `detect`, `extract`, `create` method.

hexdocs: https://hexdocs.pm/sitesx/Sitesx.Domain.html

#### `Sitesx.Helpers`. Generate URL with subdomain for controller or templates along with [Phoenix.HTML.SimplifiedHelpers.URL](https://hexdocs.pm/phoenix_html_simplified_helpers/1.1.1/Phoenix.HTML.SimplifiedHelpers.URL.html)

hexdocs: https://hexdocs.pm/sitesx/Sitesx.Helpers.html

#### `Sitesx.Plug`. Stores Sitesx model into private on Plug struct.

hexdocs: https://hexdocs.pm/sitesx/Sitesx.Plug.html

#### `Sitesx.Q`. Ecto Query Helper along with Sitesx.Plug

hexdocs: https://hexdocs.pm/sitesx/Sitesx.Q.html

## Documentation

hexdocs: https://hexdocs.pm/sitesx
