defmodule NetworkManager.AP do
  use GenServer
  require Logger

  @ap_ip "192.168.24.1/24"

  defmodule State do
    defstruct active: false
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %State{}}
  end

  def start do
    GenServer.call(__MODULE__, :start)
  end

  def active do
    GenServer.call(__MODULE__, :active)
  end

  def handle_call(:active, _from, state) do
    state.active
  end

  def handle_call(:start, _from, state) do
    Logger.info "Start AP Mode"
    System.cmd("ip", ["addr", "add", @ap_ip, "dev", "wlan0"])
    System.cmd("dnsmasq", ["--dhcp-lease", "/root/dnsmasq.lease"])
    result = System.cmd("hostapd", ["-B", "-d", "/etc/hostapd/hostapd.conf"])
    Logger.info "hostapd: #{inspect result}"
    {:reply, :ok, %State{state | active: true}}
  end

end
