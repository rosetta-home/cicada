defmodule DeviceManager.Application do
  alias DeviceManager.{Discovery, Client}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      worker(Client, [])
    ]

    opts = [strategy: :one_for_one, name: DeviceManager.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
