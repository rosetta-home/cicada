defmodule Cicada.NetworkManager.Client do
  use GenServer
  require Logger
  alias Nerves.NetworkInterface
  alias Cicada.NetworkManager.Interface
  alias Cicada.{NetworkManager, EventManager}

  @ap_ip "192.168.24.1"

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.info "Starting Network Manager"
    Registry.register(Nerves.Udhcpc, "wlan0", [])
    interfaces = NetworkInterface.interfaces
    |> Enum.map(fn i ->
      NetworkInterface.setup(i, %{})
      Registry.register(Nerves.NetworkInterface, i, [])
      Registry.register(Nerves.Udhcpc, i, [])
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

  def handle_info({Nerves.NetworkInterface, :ifchanged, msg}, state) do
    Logger.info "ifchanged: #{inspect msg}"
    state = handle_interface(msg, state)
    {:noreply, interface_changed(msg, state)}
  end

  def handle_info({Nerves.NetworkInterface, :ifadded, msg}, state) do
    Logger.info "ifadded: #{inspect msg}"
    state = handle_interface(msg, state)
    {:noreply, interface_changed(msg, state)}
  end

  def handle_info({Nerves.NetworkInterface, :ifremoved, _msg}, state), do: {:noreply, state}

  def handle_info({Nerves.NetworkInterface, :ifrenamed, _msg}, state), do: {:noreply, state}

  def handle_info({Nerves.Udhcpc, :bound, msg}, state) do
    :timer.sleep 1000
    Logger.info "WiFi Connected"
    state = handle_interface(msg, state)
    {:noreply, interface_changed(msg, state)}
  end
  def handle_info({Nerves.Udhcpc, type, msg}, state) do
    Logger.info "Udhcpc: #{inspect type} - #{inspect msg}"
    {:noreply, state}
  end

  def handle_call(:register, {pid, _ref}, state) do
    Registry.register(EventManager.Registry, NetworkManager, pid)
    {:reply, :ok, state}
  end

  def handle_interface(msg, state) do
    NetworkInterface.setup(msg.ifname, %{})
    Registry.register(Nerves.NetworkInterface, msg.ifname, [])
    Registry.register(Nerves.Udhcpc, msg.ifname, [])
    i = %Interface{
      ifname: msg.ifname,
      settings: settings(msg.ifname),
      status: status(msg.ifname),
    }
    interfaces = [i] ++ state.interfaces |> Enum.uniq_by(fn intf -> intf.ifname end) 
    #interface = interfaces |> active_interface
    Logger.info "Added Interface: #{inspect interfaces}"
    %NetworkManager.State{state | interfaces: interfaces}
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
