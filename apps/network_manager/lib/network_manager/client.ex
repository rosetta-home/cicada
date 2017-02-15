defmodule NetworkManager.Client do
  use GenServer
  require Logger
  alias Nerves.NetworkInterface
  alias NetworkManager.Interface

  @wifi_creds "/root/creds"

  defmodule State do
    defstruct ip: nil, wpa_pid: nil, bound_timer: nil
  end

  defmodule NetworkEventHandler do
    use GenEvent
    def init(parent) do
      {:ok, parent}
    end

    def handle_event({:nerves_network_interface, _, type, msg} = ev, parent) do
      Logger.debug "Network Message: #{inspect ev}"
      send(parent, {type, msg})
      {:ok, parent}
    end

    def handle_event(ev, state) do
      {:ok, state}
    end
  end

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.info "Starting Network Manager"
    GenEvent.add_handler(NetworkInterface.event_manager, NetworkEventHandler, self)
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
    #NetworkManager.WiFi.start
    Process.send_after(self, :init_network, 1000)
    Process.send_after(self, :ifup, 20_000)
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
          false -> NetworkManager.APMode.start
          true -> Process.send_after(self, :reset_wifi, 5*60_000)
        end
      %Interface{} -> :ok
    end
    {:noreply, state}
  end

  def handle_info({:ifchanged, msg}, state) do
    old_interface = state.interface
    interfaces = state.interfaces |> update_interface(msg)
    interface = interfaces |> active_interface
    state = %NetworkManager.State{state | interfaces: interfaces, interface: interface}
    #Only broadcast on network status change, up or down.
    case interface |> ifup do
      true when old_interface == nil -> state |> dispatch
      false when not old_interface |> is_nil -> state |> dispatch
      _ -> :ok
    end
    {:noreply, state}
  end

  def dispatch(event) do
    EventManager.dispatch(NetworkManager, event)
  end

  def update_interface(interfaces, ifchanged) do
    interfaces
    |> Enum.map(fn interface ->
      case ifchanged.ifname == interface.ifname do
        true ->
          %Interface{interface |
            settings: settings(interface.ifname),
            status: status(interface.ifname),
          }
        false -> interface
      end
    end)
  end

  def active_interface(interfaces) do
    interfaces |> Enum.find(fn interface -> interface |> ifup end)
  end

  def ifup(%Interface{status: %{operstate: :up}, settings: %{ipv4_address: ip}}), do: true
  def ifup(%Interface{}), do: false

  def settings(ifname), do: NetworkInterface.settings(ifname) |> elem(1)

  def status(ifname), do: NetworkInterface.status(ifname) |> elem(1)

  def handle_info(:start_ap, state) do
    Logger.info "No IP Address bound. Resetting network creds and restarting..."
    reset_network
    Nerves.Firmware.reboot(:graceful)
  end

  def handle_call(:register, from, state) do
    Registry.register(EventManager.Registry, NetworkManager, [from])
    {:reply, :ok, state}
  end

  def handle_call(:scan, _from, state) do
    ssids = Nerves.WpaSupplicant.scan(state.wpa_pid)
    |> Enum.uniq_by(fn network -> network.ssid end)
    {:reply, ssids, state}
  end

  def get_creds do
    {:ok, creds} = File.read(@wifi_creds)
    String.split(creds |> Cipher.decrypt, "\n\n", parts: 2, trim: true)
  end

  def scan do
    GenServer.call(__MODULE__, :scan, 30000)
  end

  def setup_wifi(state) do
    Logger.info "Setting Up WiFi"
    case File.exists?(@wifi_creds) do
      true ->
        join_network
        state
      false -> ap_mode(state)
    end
  end

  def write_creds(kv) do
    Logger.info "Creds: #{inspect kv}"
    {_key, ssid} = List.keyfind(kv, "ssid", 0)
    {_key, psk} = List.keyfind(kv, "psk", 0)
    Logger.info "SSID: #{inspect ssid} PSK: #{inspect psk}"
    st = ssid <> "\n\n" <> psk |> Cipher.encrypt
    File.write(@wifi_creds, st)
    :ok
  end

  def join_network do
    case get_creds do
      [ssid, psk] -> Nerves.InterimWiFi.setup("wlan0", ssid: ssid, key_mgmt: :"WPA-PSK", psk: psk)
      _other -> reset_network
    end
    Process.send_after(__MODULE__, :start_timer, 1)
  end

  def reset_network do
    :ok = File.rm(@wifi_creds)
  end

  def ap_mode(state) do
    Logger.info "Start AP Mode"
    System.cmd("ip", ["addr", "add", "192.168.24.1/24", "dev", "wlan0"])
    System.cmd("dnsmasq", ["--dhcp-lease", "/root/dnsmasq.lease"])
    System.cmd("hostapd", ["-B", "-d", "/etc/hostapd/hostapd.conf"])
    System.cmd("/usr/sbin/wpa_supplicant",  ["-i", "wlan0", "-C", "/var/run/wpa_supplicant", "-B"])
    {:ok, pid} = Nerves.WpaSupplicant.start_link("/var/run/wpa_supplicant/wlan0")
    Nerves.WpaSupplicant.scan(pid)
    %{state | wpa_pid: pid}
  end

end
