defmodule Sitesx.Mixfile do
  use Mix.Project

  @description """
  A Phoenix SubDomainer which makes subdomain using DigitalOcean, Cloudflare, etc. API and contains convenient view helper interface along with Plug and Ecto
  """

  def project do
    [app: :sitesx,
     name: "Sitesx",
     version: "0.1.2",
     elixir: ">= 1.4",
     description: @description,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps(),
     source_url: "https://github.com/ikeikeikeike/sitesx"
   ]
  end

  def application do
    [extra_applications: [:logger, :con_cache, :public_suffix, :ecto, :plug, :chexes, :phoenix_html_simplified_helpers],
     mod: {Sitesx.Application, []}]
  end

  defp deps do
    [
      {:ecto, "~> 2.1"},
      {:plug, "~> 1.3"},
      {:con_cache, "~> 0.12"},
      {:public_suffix, "~> 0.5"},
      {:chexes, github: "ikeikeikeike/chexes"},
      {:phoenix_html_simplified_helpers, "~> 1.1"},

      {:oceanex, "~> 0.2", optional: true},
      # Below is for oceanex, it's having old packages.
      {:idna, "~> 5.0.2", optional: true, override: true},
      {:hackney, "~> 1.8", optional: true, override: true},

      {:credo, "~> 0.8", only: :dev},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.16", only: :dev},
      {:inch_ex, ">= 0.0.0",  only: :docs},
    ]
  end

  defp package do
    [ maintainers: ["Tatsuo Ikeda / ikeikeikeike"],
      licenses: ["MIT"],
      links: %{"github" => "https://github.com/ikeikeikeike/sitesx"} ]
  end
end
