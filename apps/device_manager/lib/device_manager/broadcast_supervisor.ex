defmodule DeviceManager.BroadcastSupervisor do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(DeviceManager.Broadcaster, []),
      worker(DeviceManager.Consumer, [], id: 1),
      worker(DeviceManager.NetworkListener, []),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
