defmodule Cicada.DeviceManager.Client do
  use GenServer
  require Logger
  alias Cicada.NetworkManager.State, as: NM
  alias Cicada.NetworkManager.Interface, as: NMInterface
  alias Cicada.{EventManager, NetworkManager, DeviceManager}

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def register_device(module) do
    GenServer.call(__MODULE__, {:register_device, module})
  end

  def start_discovery do
    GenServer.cast(__MODULE__, :start_discovery)
  end

  def dispatch(event) do
    EventManager.dispatch(DeviceManager, event)
  end

  def init(:ok) do
    NetworkManager.register
    {:ok, %{started: false, discover: []}}
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

  def handle_info(mes, state) do
    {:noreply, state}
  end

  def handle_call(:register, {pid, _ref}, state) do
    Registry.register(EventManager.Registry, DeviceManager, pid)
    {:reply, :ok, state}
  end

  def handle_call({:register_device, module}, _from, state) do
    {:reply, :ok, %{ state | discover: [module] ++ state.discover }}
  end

  def handle_cast(:start_discovery, state) do
    DeviceManager.DiscoverySupervisor.start_link(state.discover)
    {:noreply, state}
  end

end
