defmodule DeviceManager.DiscoverySupervisor do
  use Supervisor
  require Logger
  alias DeviceManager.Discovery

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Discovery.HVAC, []),
      worker(Discovery.Light, []),
      worker(Discovery.MediaPlayer, []),
      worker(Discovery.WeatherStation, []),
      worker(Discovery.SmartMeter, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
