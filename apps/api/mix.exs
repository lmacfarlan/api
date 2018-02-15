defmodule Api.MixProject do
  use Mix.Project

  @version File.read!("../../VERSION") |> String.trim

  def project do
    [
      app: :api,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :cowboy, :plug],
      mod: {Api.Application, []}
    ]
  end

  defp deps do
    [
      {:distillery, "1.5.1", runtime: false},
      {:cowboy, "1.1.2"},
      {:plug, "1.4.3"},
      {:pilot, git: "git@github.com:metismachine/pilot.git", branch: "development"},
      {:poison, "3.1.0"},
      {:data, in_umbrella: true}
    ]
  end
end
