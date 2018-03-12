defmodule Cicada.DeviceManager.Client do
  use GenServer
  require Logger
  alias Cicada.NetworkManager.State, as: NM
  alias Cicada.{EventManager, NetworkManager}

  def start_link(plugins) do
    GenServer.start_link(__MODULE__, plugins, name: __MODULE__)
  end

  def init(plugins) do
    NetworkManager.register
    ssdp_mon = Process.monitor(SSDP.Client)
    mdns_mon = Process.monitor(Mdns.Client)
    state = %{started: false, ssdp_mon: ssdp_mon, mdns_mon: mdns_mon}
    state =
      case NetworkManager.up() do
        true ->
          start_services()
          %{state | started: true}
        false -> state
      end
    {:ok, pid} = Cicada.DeviceManager.DiscoverySupervisor.start_link(plugins)
    {:ok, state}
  end

  def handle_info(%NM{current_address: ip}, %{started: false} = state) when ip != nil do
    start_services()
    {:noreply, %{state | started: true}}
  end

  def handle_info(%NM{}, state) do
    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{ssdp_mon: ref} = state) do
    Logger.info "Starting SSDP Client"
    :timer.sleep(1000)
    ssdp_mon = Process.monitor(SSDP.Client)
    SSDP.Client.start()
    {:noreply, %{state | ssdp_mon: ssdp_mon}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{mdns_mon: ref} = state) do
    Logger.info "Starting mDNS Client"
    :timer.sleep(1000)
    mdns_mon = Process.monitor(Mdns.Client)
    Mdns.Client.start()
    {:noreply, %{state | mdns_mon: mdns_mon}}
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
