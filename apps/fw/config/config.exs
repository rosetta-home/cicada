# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config
require Logger

config :logger, level: :info

config :nerves, :firmware,
  fwup_conf: "config/rpi3/fwup.conf",
  rootfs_additions: "config/rpi3/rootfs-additions"

nerves = System.get_env("NERVES")
inter = System.get_env("INTERFACE")

Logger.info "NERVES: #{nerves}"
Logger.info "INTERFACE: #{inter}"

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.Project.config[:target]}.exs"
