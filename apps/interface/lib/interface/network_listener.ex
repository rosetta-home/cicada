defmodule Interface.NetworkListener do
  use GenServer
  require Logger
  alias NetworkManager.State, as: NM
  alias NetworkManager.Interface, as: NMInterface

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    EventManager.Consumer.start_link(self, fn
      %NM{} -> true
      _ -> false
    end)
    Interface.TCPServer.start_link
    Mdns.Server.add_service(%Mdns.Server.Service{
      domain: "rosetta.local",
      data: :ip,
      ttl: 120,
      type: :a
    })
    Mdns.Server.start
    {:ok, %{}}
  end

  def handle_info(%NM{interface: %NMInterface{settings: %{ipv4_address: address}, status: %{operstate: :up}}}, state) do
    Logger.info "mDNS IP Set: #{inspect address}"
    Mdns.Server.set_ip(address)
    {:noreply, state}
  end

  def handle_info(%NM{}, state) do
    {:noreply, state}
  end

  def handle_info(mes, state) do
    {:noreply, state}
  end

end
