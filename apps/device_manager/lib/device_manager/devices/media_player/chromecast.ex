defmodule DeviceManager.Device.MediaPlayer.Chromecast do
  use GenServer
  require Logger

  @behaviour DeviceManager.Behaviour.MediaPlayer

  def start_link(id, device) do
    GenServer.start_link(__MODULE__, {id, device}, name: id)
  end

  def play(pid, url \\ "") do
    GenServer.call(pid, {:play, url})
  end

  def pause(pid) do
    GenServer.call(pid, :pause)
  end

  def set_volume(pid, volume) do
    GenServer.call(pid, {:volume, volume})
  end

  def status(pid) do
    GenServer.call(pid, :status)
  end

  def device(pid) do
    GenServer.call(pid, :device)
  end

  def update_state(_pid, _state) do
    :ok
  end

  def get_id(device) do
    :"Chromecast-#{device.payload["id"]}"
  end

  def init({id, device}) do
    {:ok, pid} = Chromecast.start_link(device.ip)
    Process.send_after(self, :update_state, 1000)
    {:ok, %DeviceManager.Device{
      module: Chromecast,
      type: :media_player,
      device_pid: pid,
      interface_pid: id,
      name: device.payload["fn"],
      state: %{}
    }}
  end

  def handle_info(:update_state, device) do
    Process.send_after(self, :update_state, 1000)
    {:noreply, %{device | state: Chromecast.state(device.device_pid)}}
  end

  def handle_cast({:update, _state}, device) do
    {:noreply, device}
  end

  def handle_call(:device, _from, device) do
    {:reply, device, device}
  end

  def handle_call({:play, _url}, _from, device) do
    Chromecast.play(device.device_pid)
    {:reply, true, device}
  end

  def handle_call(:pause, _from, device) do
    Chromecast.pause(device.device_pid)
    {:reply, true, device}
  end

  def handle_call({:volume, volume}, _from, device) do
    Chromecast.set_volume(device.device_pid, volume)
    {:reply, true, device}
  end

  def handle_call(:status, _from, device) do
    Chromecast.state(device.device_pid)
    {:reply, true, device}
  end

end

defmodule DeviceManager.Discovery.MediaPlayer.Chromecast do
  use GenEvent
  require Logger

  def init do
      {:ok, []}
  end

  def handle_event({:"_googlecast._tcp.local", device}, parent) do
      send(parent, {:googlecast, device})
      {:ok, parent}
  end

  def handle_event(_other, parent) do
      {:ok, parent}
  end

end
