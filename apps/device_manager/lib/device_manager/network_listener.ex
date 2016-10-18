defmodule DeviceManager.NetworkListener do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    DeviceManager.NetworkConsumer.start_link(self)
  end

  def handle_info({:bound, ip}, state) do
    Logger.info "Got IP"
    Mdns.start([], [])
    SSDP.start([], [])
    Lifx.start([], [])
    DeviceManager.DiscoverySupervisor.start_link
    {:noreply, state}
  end

end
