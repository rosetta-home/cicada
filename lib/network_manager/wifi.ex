defmodule Cicada.NetworkManager.WiFi do
  use GenServer
  require Logger

  @wifi_creds "/root/creds"

  defmodule State do
    defstruct wpa_pid: nil
  end

  #Server

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def join do
    GenServer.call(__MODULE__, :join)
  end

  def scan do
    GenServer.call(__MODULE__, :scan, 30000)
  end

  #Callbacks

  def init(:ok) do
    System.cmd("modprobe", ["brcmfmac"])
    {_, pid} = case File.exists?("/usr/sbin/wpa_supplicant") do
      true ->
        System.cmd("/usr/sbin/wpa_supplicant",  ["-i", "wlan0", "-C", "/var/run/wpa_supplicant", "-B"])
        Logger.debug "WpaSupplicant Started"
        {:ok, wpa} = Nerves.WpaSupplicant.start_link("wlan0", "/var/run/wpa_supplicant/wlan0")
      _ -> {:noop, :noop}
    end
    case creds? do
      true -> Process.send_after(__MODULE__, :join, 0)
      false -> :ok
    end
    {:ok, %State{wpa_pid: pid}}
  end

  def handle_info(:join, state) do
    join_network(state.wpa_pid)
    {:noreply, state}
  end

  def handle_info({Nerves.WpaSupplicant, _type, _msg}, state), do: {:noreply, state}

  def handle_call(:scan, _from, state) do
    ssids = Nerves.WpaSupplicant.scan(state.wpa_pid)
    |> Enum.uniq_by(fn network -> network.ssid end)
    {:reply, ssids, state}
  end

  def handle_call(:join, _from, state) do
    join_network(state.wpa_pid)
    {:reply, :ok, state}
  end

  #Util

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

  def join_network(wpa_pid) do
    case get_creds do
      [ssid, psk] ->
        Nerves.InterimWiFi.setup("wlan0", ssid: ssid, key_mgmt: :"WPA-PSK", psk: psk)
        :ok
      _other ->
        delete_creds
        :error
    end
  end

end
