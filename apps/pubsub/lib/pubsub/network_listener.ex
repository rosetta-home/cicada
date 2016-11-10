defmodule PubSub.NetworkListener do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    PubSub.NetworkConsumer.start_link(self)
  end

  def handle_info({:bound, ip}, state) do
    Logger.info "Got IP"
    :nodefinder.multicast_start()
    :nodefinder.multicast_discover(5000)
    {:noreply, state}
  end

end
