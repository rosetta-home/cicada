defmodule DataManager.Supervisor do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(DataManager.DeviceConsumer, []),
      worker(DataManager.Broadcaster, []),
      worker(DataManager.MetricHistory, [])
    ]
    supervise(children, strategy: :one_for_one)
  end

end
