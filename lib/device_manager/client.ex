defmodule Cicada.DeviceManager.Client do
  use GenServer
  require Logger
  alias Cicada.NetworkManager.State, as: NM
  alias Cicada.NetworkManager.Interface, as: NMInterface
  alias Cicada.{EventManager, NetworkManager}

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    NetworkManager.register
    Process.send_after(__MODULE__, :discover, 0)
    {:ok, %{started: false}}
  end

  def handle_info(%NM{bound: true}, %{started: started} = state)
  when started == false do
    Logger.info "Starting SSDP"
    SSDP.Client.start
    Logger.info "Starting mDNS"
    Mdns.Client.start
    {:noreply, %{state | started: true}}
  end

  def handle_info(%NM{}, state) do
    {:noreply, state}
  end

  def handle_info(:discover, state) do
    case Cicada.DeviceManager.Registry.get do
      [] -> Process.send_after(__MODULE__, :discover, 10)
      discovery ->
        Logger.info "Launching DeviceManager.Client: #{inspect discovery}"
        {:ok, pid} = Cicada.DeviceManager.DiscoverySupervisor.start_link(discovery)
    end
    {:noreply, state}
  end

  def handle_call(:register, {pid, _ref}, state) do
    Logger.info "Registering: #{inspect pid}"
    Registry.register(EventManager.Registry, DeviceManager, pid)
    {:reply, :ok, state}
  end

end
