defmodule VoiceControl.Mixfile do
  use Mix.Project

  def project do
    [app: :voice_control,
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

  def application do
    [
      applications: [:logger, :movi],
      mod: {VoiceControl, []}
    ]
  end

  defp deps do
    [{:movi, "~> 0.1.1"}]
  end
end
