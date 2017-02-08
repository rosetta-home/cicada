defmodule Fw.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi3"

  def project do
    [app: :fw,
     version: "0.0.1",
     target: @target,
     archives: [nerves_bootstrap: "~> 0.1.4"],
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps ++ system(@target)]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Fw, []},
     applications: [:logger, :nerves, :nerves_system_rpi3, :network_manager, :cpu_mon, :interface, :device_manager, :data_manager, :api, :voice_control, :nerves_firmware_http, :poison]]
  end

  def deps do
    [
      {:nerves, "~> 0.3.0"},
      {:network_manager, in_umbrella: true},
      {:interface, in_umbrella: true},
      {:device_manager, in_umbrella: true},
      {:data_manager, in_umbrella: true},
      {:cpu_mon, in_umbrella: true},
      {:api, in_umbrella: true},
      {:voice_control, in_umbrella: true},
      {:nerves_firmware_http, github: "nerves-project/nerves_firmware_http"},
      {:poison, "~> 3.0", [env: :prod, hex: :poison, override: true, manager: :mix]}
    ]
  end

  def system("rpi3") do
    [{:"nerves_system_rpi3", git: "https://github.com/NationalAssociationOfRealtors/nerves_system_rpi3.git", tag: "v0.7.2" }]
  end

  def aliases do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end
end
