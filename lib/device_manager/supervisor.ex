defmodule Cicada.DeviceManager.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Cicada.DeviceManager.Registry, []),
      worker(Cicada.DeviceManager.Client, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
