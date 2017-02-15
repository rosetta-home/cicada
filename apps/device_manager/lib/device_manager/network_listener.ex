defmodule DeviceManager.NetworkListener do
  use GenServer
  require Logger
  alias NetworkManager.State, as: NM
  alias NetworkManager.Interface, as: NMInterface

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    NetworkManager.register
    {:ok, %{}}
  end

  def handle_info(%NM{interface: %NMInterface{settings: %{ipv4_address: address}, status: %{operstate: :up}}}, state) do
    Logger.info "Device Manager IP: #{inspect address}"
    DeviceManager.ApplicationSupervisor.start_apps
    DeviceManager.ApplicationSupervisor.start_discovery
    {:noreply, state}
  end

  def handle_info(%NM{}, state) do
    {:noreply, state}
  end

  def handle_info(mes, state) do
    {:noreply, state}
  end

end
