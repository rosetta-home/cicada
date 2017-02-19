defmodule DataManager.Mixfile do
  use Mix.Project

  def project do
    [app: :data_manager,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:logger, :device_manager, :statistics],
      mod: {DataManager.Application, []},
      env: [ history_length: 1000 ]
    ]
  end

  defp deps do
    [
      {:device_manager, in_umbrella: true},
      {:statistics, "~> 0.4.1"}
    ]
  end
end
