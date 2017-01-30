defmodule NetworkManager.Client do
  use GenServer
  require Logger
  alias Nerves.Networking

  @key_management :"WPA-PSK"
  @interface System.get_env("INTERFACE")
  @ssid System.get_env("SSID")
  @psk System.get_env("PSK")

  defmodule WifiHandler do
    use GenEvent
    def init(parent) do
      {:ok, %{:parent => parent}}
    end

    def handle_event({:udhcpc, _, :bound, info}, state) do
      Logger.info "Wifi bound: #{inspect info}"
      send(state.parent, {:bound, info})
      {:ok, state}
    end

    def handle_event(ev, state) do
      {:ok, state}
    end
  end

  def get_ip(interface) do
    Logger.info "Getting IP address for interface #{interface}"
    :inet.getifaddrs()
      |> elem(1)
      |> Enum.filter(fn(intf) -> elem(intf, 0) == to_char_list(interface) end)
      |> Enum.at(0)
      |> elem(1)
      |> Keyword.get(:addr)
      |> IO.inspect
  end

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    unless :os.type == {:unix, :darwin} do
      Process.send_after(self, :start_network, 0)
    else
      Process.send_after(self, :get_ip, 0)
    end
    {:ok, %{}}
  end

  def handle_info(:start_network, state) do
    Logger.info "Starting Network Manager"
    case @interface do
      "eth0" ->
        {:ok, _} = String.to_atom(@interface) |> Networking.setup
        Process.send_after(self, :get_ip, 1000)
      "wlan0" ->
        GenEvent.add_handler(Nerves.NetworkInterface.event_manager, WifiHandler, self)
        setup_wifi
    end
    {:noreply, state}
  end

  def handle_info(:get_ip, state) do
    ip = get_ip(@interface)
    Logger.info "Got IP: #{inspect ip}"
    :timer.sleep 1000
    NetworkManager.Broadcaster.sync_notify({:bound, ip})
    Logger.info "Broadcasted"
    {:noreply, state}
  end

  def handle_info({:bound, info}, state) do
    Process.send_after(self, :get_ip, 1000)
    {:noreply, state}
  end

  def setup_wifi do
    Logger.info "Setting Up WiFi"
    #Nerves.InterimWiFi.setup(@interface, ssid: @ssid, key_mgmt: @key_management, psk: @psk)
  end

end
