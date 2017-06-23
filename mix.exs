defmodule Sitesx.Mixfile do
  use Mix.Project

  @description """
  A Phoenix SubDomainer which makes subdomain using DigitalOcean, Cloudflare, etc.
  API and contains convenient view helper interface along with Plug and Ecto
  """

  def project do
    [app: :sitesx,
     name: "Sitesx",
     version: "0.10.3",
     elixir: ">= 1.4.0",
     elixirc_paths: elixirc_paths(Mix.env),
     description: @description,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     package: package(),
     deps: deps(),
     source_url: "https://github.com/ikeikeikeike/sitesx"
   ]
  end

  def application do
    [extra_applications: [
      :logger,
      :ecto,
      :plug,
      :chexes,
      :con_cache,
      :public_suffix,
      :phoenix_html_simplified_helpers,
    ], mod: {Sitesx.Application, []}]
  end

  defp deps do
    [
      {:ecto, "~> 2.1"},
      {:plug, "~> 1.3"},

      # Override
      # {:oceanex, ">= 0.2.0"}, {:httpoison, ">= 0.11.1", override: true},
      # {:public_suffix, ">= 0.5.0"}, {:idna, ">= 2.0.0", override: true},

      # Older versions
      # {:oceanex, ">= 0.2.0", optional: true},
        # {:httpoison, ">= 0.8.0"},
        # {:hackney, "== 1.6.3 or == 1.6.5"},
        # {:poison, "~> 2.0 or ~> 2.2"},
      # {:public_suffix, ">= 0.5.0"},
        # {:idna, "~> 1.2"},

      # Below is just update to mix file's package version.
      {:httpoison, ">= 0.11.1"},
      {:oceanex, github: "ikeikeikeike/oceanex", branch: "feature/update-mix"},
      {:public_suffix, github: "ikeikeikeike/publicsuffix-elixir", branch: "topic/update-mix"},

      {:con_cache, "~> 0.12"},
      {:chexes, "~> 0.1"},
      {:phoenix_html_simplified_helpers, "~> 1.1"},

      {:postgrex, ">= 0.0.0", only: [:dev, :test]},
      {:phoenix, "~> 1.3.0-rc.2", only: :test},
        {:poison, "~> 2.0 or ~> 2.2 or >= 3.0.0"},

      {:credo, "~> 0.8", only: [:dev, :test]},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.16", only: :dev},
      {:inch_ex, ">= 0.0.0",  only: :docs},
    ]
  end

  defp package do
    [maintainers: ["Tatsuo Ikeda / ikeikeikeike"],
     licenses: ["MIT"],
     links: %{"github" => "https://github.com/ikeikeikeike/sitesx"}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    ["test": ["ecto.drop --quiet", "ecto.create", "ecto.migrate", "run priv/repo/seeds.exs", "test"]]
  end
end
