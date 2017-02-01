defmodule NetworkManager.Client do
  use GenServer
  require Logger
  alias Nerves.NetworkInterface
  alias Nerves.Networking

  @wifi_creds "/root/creds"

  defmodule State do
    defstruct ip: nil, wpa_pid: nil, bound_timer: nil
  end

  defmodule InterfaceHandler do
    use GenEvent
    def init(parent) do
      {:ok, %{:parent => parent}}
    end

    def handle_event({:udhcpc, _, :bound, info}, state) do
      Logger.info "Interface bound: #{inspect info}"
      send(state.parent, {:bound, info})
      {:ok, state}
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
    GenEvent.add_handler(Nerves.NetworkInterface.event_manager, InterfaceHandler, self)
    #If running locally, just get the IP, otherwise start the network stack
    unless :os.type == {:unix, :darwin} do
      Process.send_after(self, :start_network, 0)
    else
      Process.send_after(self, {:get_ip, %{ifname: "wlan0"}}, 0)
    end
    {:ok, %State{}}
  end

  def handle_info({:bound, info}, state) do
    Process.send_after(self, {:get_ip, info}, 1000)
    Process.cancel_timer(state.bound_timer)
    {:noreply, %State{state | bound_timer: nil}}
  end

  def handle_info(:start_network, state) do
    Logger.info "Test eth0 interface first"
    Networking.setup :eth0
    :timer.sleep 1000
    {:ok, eth_status} = NetworkInterface.status("eth0")
    IO.inspect eth_status
    state = case eth_status.operstate do
      :down -> setup_wifi(state)
      :up ->
        Process.send_after(self, {:get_ip, %{ifname: "eth0"}}, 0)
        state
    end
    {:noreply, state}
  end

  def handle_info({:get_ip, info}, state) do
    Logger.info "Getting IP for interface: #{inspect info}"
    {:ok, settings} = NetworkInterface.settings info.ifname
    ip = settings.ipv4_address
    Logger.info "Got IP: #{inspect ip}"
    :timer.sleep 1000
    NetworkManager.Broadcaster.sync_notify({:bound, ip})
    Logger.info "IP Broadcasted"
    {:noreply, state}
  end

  def handle_info(:start_timer, state) do
    timer = Process.send_after(self, :start_ap, 20000)
    {:noreply, %State{state | bound_timer: timer}}
  end

  def handle_info(:start_ap, state) do
    Logger.info "No IP Address bound. Restting Network and restarting..."
    reset_network
    Nerves.Firmware.reboot(:graceful)
  end

  def handle_call(:scan, _from, state) do
    ssids = Nerves.WpaSupplicant.scan(state.wpa_pid)
    |> Enum.uniq_by(fn network -> network.ssid end)
    {:reply, ssids, state}
  end

  def get_creds do
    {:ok, creds} = File.read(@wifi_creds)
     String.split(creds, "\n\n", parts: 2, trim: true)
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
    #TODO encrypt this!!!
    st = ssid <> "\n\n" <> psk
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
    System.cmd("ip", ["route", "add", "default", "via", "192.168.11.1"])
    System.cmd("ip", ["link", "set", "wlan0", "up"])
    System.cmd("ip", ["addr", "add", "192.168.24.1/24", "dev", "wlan0"])
    System.cmd("dnsmasq", ["--dhcp-lease", "/root/dnsmasq.lease"])
    System.cmd("hostapd", ["-B", "-d", "/etc/hostapd/hostapd.conf"])
    System.cmd("/usr/sbin/wpa_supplicant",  ["-i", "wlan0", "-C", "/var/run/wpa_supplicant", "-B"])
    :timer.sleep 1000
    {:ok, pid} = Nerves.WpaSupplicant.start_link("/var/run/wpa_supplicant/wlan0")
    Nerves.WpaSupplicant.scan(pid)
    %{state | wpa_pid: pid}
  end

end
