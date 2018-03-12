defmodule Cicada.Mixfile do
  use Mix.Project

  def project do
    [app: :cicada,
     version: "0.1.0",
     build_path: "_build",
     config_path: "config/config.exs",
     deps_path: "deps",
     lockfile: "mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:logger, :nerves_network, :nerves_wpa_supplicant, :cowboy, :mdns, :ssdp, :cipher, :statistics, :os_mon,], #:movi],
      mod: {Cicada.Application, []},
      env: [
        cipher: [
          keyphrase: System.get_env("CIPHER_KEYPHRASE"),
          ivphrase: System.get_env("CIPHER_IV"),
          magic_token: System.get_env("CIPHER_TOKEN")
        ]
      ]
    ]
  end


  defp deps do
    [
      {:nerves_network, "~> 0.3.6"},
      {:poison, "~> 3.0", override: true},
      {:cipher, ">= 1.3.0"},
      {:cowboy, "~> 1.0"},
      {:mdns, "~> 0.1.5"},
      {:ssdp, "~> 0.1.6"},
      #{:movi, "~> 0.1.1"},
      {:statistics, "~> 0.4.1"},
    ]
  end
end
