defmodule NetworkManager.Client do
  use GenServer
  require Logger

  @key_management :"WPA-PSK"
  @interface System.get_env("INTERFACE")
  @nerves System.get_env("NERVES")
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

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.send_after(self, :start_network, 0)
    {:ok, %{}}
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

  def handle_info(:start_network, state) do
    Logger.info "Starting Network Manager"
    case @nerves do
      "true" ->
        GenEvent.add_handler(Nerves.NetworkInterface.event_manager, WifiHandler, self)
        setup_wifi
      _ ->
        ip = get_ip(@interface)
        Logger.info "Got IP: #{inspect ip}"
        :timer.sleep 1000
        NetworkManager.Broadcaster.sync_notify({:bound, ip})
        Logger.info "Broadcasted"
    end
    {:noreply, state}
  end

  def handle_info({:bound, info}, state) do
    Logger.info "IP Address Bound"
    :timer.sleep(1000)
    {:ok, ip} = :inet_parse.address(to_char_list(info.ipv4_address))
    Logger.info "#{inspect ip}"
    NetworkManager.Broadcaster.sync_notify({:bound, ip})
    {:noreply, state}
  end

  def setup_wifi do
    Logger.info "Setting Up WiFi"
    Nerves.InterimWiFi.setup(@interface, ssid: @ssid, key_mgmt: @key_management, psk: @psk)
  end

end
