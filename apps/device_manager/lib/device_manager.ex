defmodule DeviceManager do
  use Application
  require Logger
  alias DeviceManager.Discovery
  alias Nerves.UART, as: Serial

  defmodule Device do
    defstruct module: nil,
      type: nil,
      pid: nil,
      name: "",
      id: "",
      state: %{}
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      worker(Discovery.HVAC, []),
      worker(Discovery.Light, []),
      worker(Discovery.MediaPlayer, []),
      worker(Discovery.WeatherStation, []),
      worker(Discovery.SmartMeter, [])
    ]
    opts = [strategy: :one_for_one, name: DeviceManager.DiscoverySupervisor]
    Supervisor.start_link(children, opts)
  end

end
