use Mix.Config

import_config if(Mix.env == :test, do: "test.exs", else: "dev.exs")
