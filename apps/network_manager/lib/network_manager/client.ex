defmodule NetworkManager.Client do
  use GenServer
  require Logger
  alias Nerves.NetworkInterface
  alias NetworkManager.Interface

  @ap_ip "192.168.24.1"

  defmodule NetworkEventHandler do
    use GenEvent
    def init(parent) do
      {:ok, parent}
    end

    def handle_event({:nerves_network_interface, _, type, msg} = ev, parent) do
      Logger.info "Network Message: #{inspect ev}"
      send(parent, {type, msg})
      {:ok, parent}
    end

    def handle_event({:udhcpc, _, :bound, msg}, parent) do
      Logger.info "Bound: #{inspect msg}"
      send(parent, {:bound, msg})
      {:ok, parent}
    end

    def handle_event(_msg, state) do
      {:ok, state}
    end

  end

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.info "Starting Network Manager"
    GenEvent.add_handler(NetworkInterface.event_manager, NetworkEventHandler, self())
    interfaces = NetworkInterface.interfaces
    |> Enum.map(fn i ->
      NetworkInterface.setup(i, %{})
      %Interface{
        ifname: i,
        settings: settings(i),
        status: status(i),
      }
    end)
    Logger.info "Network Interfaces: #{inspect interfaces}"
    Process.send_after(self(), :init_network, 1000)
    Process.send_after(self(), :ifup, 5_000)
    {:ok, %NetworkManager.State{interfaces: interfaces}}
  end

  def handle_info(:init_network, state) do
    interface = state.interfaces |> active_interface
    state = %NetworkManager.State{state | interface: interface}
    state |> dispatch
    {:noreply, state}
  end

  def handle_info(:ifup, state) do
    case active_interface(state.interfaces) do
      nil ->
        case NetworkManager.WiFi.creds? do
          false -> NetworkManager.AP.start
          true -> :ok #Do not reset creds.
        end
      %Interface{} -> :ok
    end
    {:noreply, state}
  end

  def handle_info({:ifchanged, msg}, state) do
    {:noreply, interface_changed(msg, state)}
  end

  def handle_info({:ifadded, msg}, state) do
    NetworkInterface.setup(msg.ifname, %{})
    i = %Interface{
      ifname: msg.ifname,
      settings: settings(msg.ifname),
      status: status(msg.ifname),
    }
    interfaces = [i] ++ state.interfaces
    interface = interfaces |> active_interface
    Logger.info "Added Interface: #{inspect interfaces}"
    {:noreply, %NetworkManager.State{state | interfaces: interfaces, interface: interface}}
  end

  def handle_info({:ifrenamed, _msg}, state), do: {:noreply, state}
  def handle_info({:ifremoved, _msg}, state), do: {:noreply, state}

  def handle_info({:bound, msg}, state) do
    :timer.sleep 1000
    {:noreply, interface_changed(msg, state)}
  end

  def handle_call(:register, {pid, _ref}, state) do
    Registry.register(EventManager.Registry, NetworkManager, pid)
    {:reply, :ok, state}
  end

  def dispatch(event) do
    EventManager.dispatch(NetworkManager, event)
  end

  def interface_changed(ifchanged, state) do
    old_interface = state.interface
    interfaces = state.interfaces |> update_interface(ifchanged.ifname)
    interface = interfaces |> active_interface
    state = %NetworkManager.State{state | interfaces: interfaces, interface: interface}
    Logger.info "Network State: #{inspect state}"
    Logger.info "Old Interface: #{inspect old_interface}"
    #Only broadcast on network status change, up or down.
    case interface |> ifup do
      true when old_interface == nil -> state |> dispatch
      false when not old_interface |> is_nil -> state |> dispatch
      _ -> :ok
    end
    state
  end

  def update_interface(interfaces, ifname) do
    interfaces
    |> Enum.map(fn interface ->
      case ifname == interface.ifname do
        true ->
          %Interface{interface |
            settings: settings(ifname),
            status: status(ifname),
          }
        false -> interface
      end
    end)
  end

  def active_interface(interfaces) do
    interfaces |> Enum.find(fn interface -> interface |> ifup end)
  end

  def ifup(%Interface{status: %{operstate: :up}, settings: %{ipv4_address: ip}}) when ip != @ap_ip do
    true
  end
  def ifup(_), do: false

  def settings(ifname), do: NetworkInterface.settings(ifname) |> elem(1)

  def status(ifname), do: NetworkInterface.status(ifname) |> elem(1)

end
