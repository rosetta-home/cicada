defmodule DeviceManager.Mixfile do
  use Mix.Project

  def project do
    [app: :device_manager,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :gen_stage, :network_manager, :lifx, :ssdp, :mdns, :chromecast, :raven_smcd, :ieq_gateway, :radio_thermostat, :meteo_stick],
     mod: {DeviceManager, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:mdns, "~> 0.1.3"},
      {:ssdp, "~> 0.1.1"},
      {:lifx, "~> 0.1.6"},
      {:chromecast, "~> 0.1.0"},
      {:meteo_stick, "~> 0.1.8"},
      {:raven_smcd, "~> 0.1.5"},
      {:ieq_gateway, "~> 0.1.3"},
      {:gen_stage, "~> 0.4"},
      {:radio_thermostat, github: "NationalAssociationOfRealtors/radio_thermostat"},
      {:voice_control, in_umbrella: true},
      {:network_manager, in_umbrella: true}
    ]
  end
end
