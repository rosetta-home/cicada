defmodule Cicada.DeviceManager.Client do
  use GenServer
  require Logger
  alias Cicada.NetworkManager.State, as: NM
  alias Cicada.NetworkManager.Interface, as: NMInterface
  alias Cicada.{EventManager, NetworkManager}

  def start_link(plugins) do
    GenServer.start_link(__MODULE__, plugins, name: __MODULE__)
  end

  def init(plugins) do
    NetworkManager.register
    state =
      case NetworkManager.up() do
        true ->
          start_services()
          %{started: true}
        false ->
          %{started: false}
      end
    {:ok, pid} = Cicada.DeviceManager.DiscoverySupervisor.start_link(plugins)
    {:ok, state}
  end

  def handle_info(%NM{bound: true}, %{started: false} = state) do
    start_services()
    {:noreply, %{state | started: true}}
  end

  def handle_info(%NM{}, state) do
    {:noreply, state}
  end

  def handle_call(:register, {pid, _ref}, state) do
    Logger.info "Registering: #{inspect pid}"
    Registry.register(EventManager.Registry, DeviceManager, pid)
    {:reply, :ok, state}
  end

  def start_services() do
    Logger.info "Starting SSDP"
    SSDP.Client.start
    Logger.info "Starting mDNS"
    Mdns.Client.start
  end

end
