# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config
require Logger
config :nerves, :firmware,
  fwup_conf: "config/rpi3/fwup.conf",
  rootfs_additions: "config/rpi3/rootfs-additions"

nerves = System.get_env("NERVES")

Logger.info "NERVES: #{nerves}"

Application.put_env(:setup, :verify_directories, false, persistent: true)
case nerves do
  "true" ->
    config :lager, log_root: '/root/logs'
    Application.put_env(:setup, :home, "/root", persistent: true)
    Application.put_env(:setup, :data_dir, "/root/logs/data.node", persistent: true)
    Application.put_env(:setup, :log_dir, "/root/logs/log.node", persistent: true)
  _ -> nil
end

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.Project.config[:target]}.exs"
