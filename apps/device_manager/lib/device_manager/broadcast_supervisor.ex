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
      worker(DeviceManager.Consumer, [], id: 2),
      worker(DeviceManager.Consumer, [], id: 3)
    ]
    supervise(children, strategy: :one_for_one)
  end
end
