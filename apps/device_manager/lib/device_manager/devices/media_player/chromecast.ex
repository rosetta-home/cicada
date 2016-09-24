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
    IO.inspect(state.media_status)
    %MediaPlayer.State{
      ip: state.ip |> :inet_parse.ntoa |> to_string,
      media_status: %{
        current_time: state.media_status["currentTime"],
        items: Enum.map(state.media_status["items"], fn(item) ->
          %MediaPlayer.State.Item{
            autoplay: item["autoplay"],
            id: item["itemId"],
            content_id: item["media"]["contentId"],
            content_type: item["media"]["contentType"],
            type: item["media"]["type"],
            duration: item["media"]["duration"],
            images: Enum.map(item["media"]["metadata"]["images"], fn(image) ->
              %MediaPlayer.State.Image{
                url: image["url"],
                width: image["width"],
                height: image["height"]
              }
            end),
            title: item["media"]["metadata"]["title"],
            subtitle: item["media"]["metadata"]["subtitle"]
          }
        end)
      },
      receiver_status: %{
        volume: state.receiver_status["status"]["volume"]["level"],
        applications: Enum.map(state.receiver_status["status"]["applications"], fn(app) ->
          %MediaPlayer.State.Application{
            id: app["appId"],
            name: app["displayName"],
            idle: app["isIdleScreen"],
            status: app["statusText"]
          }
        end)
      }
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
