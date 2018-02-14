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
      extra_applications: [
        :logger,
        :ecto,
        :postgrex,
      ],
      mod: {Data.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:postgrex,       ">= 0.0.0"},
      {:xandra,         "~> 0.8.0"},
      {:ecto,           "~> 2.1"},
      {:poison,         "~> 3.1", override: true},
      {:secure_random,  "~> 0.5"},
    ]
  end
end
