defmodule DeviceManager.Device.MediaPlayer.Chromecast do
  use GenServer
  require Logger
  alias DeviceManager.Device.MediaPlayer
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

  def update_state(pid, state) do
    GenServer.call(pid, {:update, state})
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
      state: %MediaPlayer.State{}
    }}
  end

  def handle_info(:update_state, device) do
    Process.send_after(self, :update_state, 1000)
    device = %{device | state:
      Chromecast.state(device.device_pid)
      |> map_state
    }
    DeviceManager.Broadcaster.sync_notify(device)
    {:noreply, device}
  end

  def handle_call({:update, _state}, _from, device) do
    {:reply, device, device}
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

  def map_state(state) do
    item = state.media_status |> Map.get("items", []) |> Enum.at(0, %{})
    media = item |> Map.get("media", %{})
    metadata = media |> Map.get("metadata", %{})
    image = metadata
      |> Map.get("images", [])
      |> Enum.at(0, %MediaPlayer.State.Image{})
    app = state.receiver_status["status"] |>  Map.get("applications", []) |> Enum.at(0, %{})

    %MediaPlayer.State{
      ip: state.ip |> :inet_parse.ntoa |> to_string,
      current_time:  state |> Map.get("current_time", 0),
      content_id: item |> Map.get("content_id", 0),
      content_type: item |> Map.get("content_type", "Unknown"),
      duration: item |> Map.get("duration", 0),
      autoplay: item |> Map.get("autoplay", false),
      image: image,
      title: metadata |> Map.get("title", ""),
      subtitle: metadata |> Map.get("subtitle", ""),
      volume: state.receiver_status["status"]["volume"]["level"],
      status: app |> Map.get("statusText", ""),
      idle: app |> Map.get("isIdleScreen", ""),
      app_name: app |> Map.get("displayName", ""),
      id: app |> Map.get("appId")
    }
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
