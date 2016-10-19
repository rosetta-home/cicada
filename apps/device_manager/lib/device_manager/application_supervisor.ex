defmodule DeviceManager.ApplicationSupervisor do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      supervisor(DeviceManager.DiscoverySupervisor, [])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def start_discovery do
    Supervisor.start_child(__MODULE__, [])
  end

  def start_apps do
    Lifx.Client.start
    SSDP.Client.start
    Mdns.Client.start
  end

end
