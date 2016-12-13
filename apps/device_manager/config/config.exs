# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config
require Logger

config :logger,
  backends: [:console],
  compile_time_purge_level: :info,
  level: :info

config :meteo_stick, tty: "/dev/ttyUSB987987"
config :raven_smcd, tty: "/dev/ttyUSB65675"
config :ieq_gateway, tty: "/dev/ttyUSB0986767"
