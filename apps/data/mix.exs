defmodule Data.MixProject do
  use Mix.Project

  def project do
    [
      app:              :data,
      version:          "0.0.1",
      build_path:       "../../_build",
      config_path:      "../../config/config.exs",
      deps_path:        "../../deps",
      lockfile:         "../../mix.lock",
      elixir:           "~> 1.6",
      start_permanent:  Mix.env() == :prod,
      deps:             deps(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Data.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:xandra,         "~> 0.9"},
      {:poison,         "3.1.0", override: true}
    ]
  end
end
