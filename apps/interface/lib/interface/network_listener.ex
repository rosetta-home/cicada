defmodule Interface.NetworkListener do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    Interface.NetworkConsumer.start_link(self)
  end

  def handle_info({:bound, ip}, state) do
    Mdns.Server.set_ip(ip)
    Mdns.Server.add_service(%Mdns.Server.Service{
      domain: "rosetta.local",
      data: :ip,
      ttl: 120,
      type: :a
    })
    Interface.TCPServer.start_link
    {:noreply, state}
  end

end
