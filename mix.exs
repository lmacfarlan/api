defmodule Oddcarl.MixProject do
  use Mix.Project

  @version File.read!("VERSION") |> String.trim

  def project do
    [
      name:             "oddcarl",
      version:          @version,
      apps_path:        "apps",
      start_permanent:  Mix.env() == :prod,
      deps:             deps()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:distillery, "1.5.1", runtime: false},
    ]
  end
end
