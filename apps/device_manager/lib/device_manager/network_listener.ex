defmodule DeviceManager.NetworkListener do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DeviceManager.NetworkConsumer.start_link(self)
  end

  def handle_info({:bound, ip}, state) do
    Logger.info "Got IP"
    DeviceManager.ApplicationSupervisor.start_apps
    DeviceManager.ApplicationSupervisor.start_discovery
    {:noreply, state}
  end

end
