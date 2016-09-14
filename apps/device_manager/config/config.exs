# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :raven_smcd, tty: "/dev/ttyUSB0"
config :meteo_stick, tty: "/dev/ttyUSB1"
config :logger, level: :info
