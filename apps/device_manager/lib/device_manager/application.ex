defmodule DeviceManager.Application do
  alias DeviceManager.{Discovery, Client}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(Discovery, [Discovery.HVAC], id: 1),
      worker(Discovery, [Discovery.Light], id: 2),
      worker(Discovery, [Discovery.MediaPlayer], id: 3),
      worker(Discovery, [Discovery.WeatherStation], id: 4),
      worker(Discovery, [Discovery.SmartMeter], id: 5),
      worker(Discovery, [Discovery.IEQ], id: 6),
      worker(Client, [])
    ]

    opts = [strategy: :one_for_one, name: DeviceManager.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
