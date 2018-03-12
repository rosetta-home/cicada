defmodule Cicada.NetworkManager.Client do
  use GenServer
  require Logger
  alias Nerves.Network
  alias Nerves.NetworkInterface
  alias Cicada.NetworkManager.Interface
  alias Cicada.{NetworkManager, EventManager}

  @ap_ip "192.168.24.1"
  @wifi_creds "/root/creds"
  @scope [:state, :network_interface]
  @target System.get_env("MIX_TARGET") || "host"

  def start_link(iface \\ "wlan0") do
    GenServer.start_link(__MODULE__, iface, name: __MODULE__)
  end

  def dispatch(event) do
    EventManager.dispatch(NetworkManager, event)
  end

  def init(iface) do
    Logger.info "Starting Network Manager: #{iface}"
    wait_until_iface_up(iface)
    case @target do
      "host" -> SystemRegistry.register()
      _ -> init_wifi(iface)
    end
    {:ok, %NetworkManager.State{iface: iface}}
  end

  def handle_info({:system_registry, :global, registry}, %NetworkManager.State{iface: iface, current_address: current} = state) do
    scope = scope(iface, [:ipv4_address])
    ip = get_in(registry, scope)
    state =
      case ip != current do
        true ->
          Logger.debug "IP Address Changed to #{ip}"
          state = %NetworkManager.State{current_address: ip, bound: true}
          dispatch(state)
        false -> state
      end
    {:noreply, state}
  end

  def handle_call(:register, {pid, _ref}, state) do
    Registry.register(EventManager.Registry, NetworkManager, pid)
    {:reply, :ok, state}
  end

  def handle_call(:up, _from, state), do: {:reply, state.bound, state}

  def init_wifi(iface) do
    case creds? do
      false -> NetworkManager.AP.start
      true ->
        SystemRegistry.register()
        join_network(iface)
    end
  end

  defp wait_until_iface_up(iface) do
    unless iface in NetworkInterface.interfaces() do
      Process.sleep(500)
      wait_until_iface_up(iface)
    end
  end

  def creds? do
    File.exists?(@wifi_creds)
  end

  def delete_creds do
    :ok = File.rm(@wifi_creds)
  end

  def get_creds do
    {:ok, creds} = File.read(@wifi_creds)
    String.split(creds |> Cipher.decrypt, "\n\n", parts: 2, trim: true)
  end

  def write_creds(ssid, psk) do
    st = ssid <> "\n\n" <> psk |> Cipher.encrypt
    File.write(@wifi_creds, st)
    :ok
  end

  defp scope(iface, append) do
    @scope ++ [iface] ++ append
  end

  def join_network(iface) do
    case get_creds() do
      [ssid, psk] -> Nerves.Network.setup(iface, ssid: ssid, key_mgmt: :"WPA-PSK", psk: psk)
      _other ->
        delete_creds
        :error
    end
  end
end
