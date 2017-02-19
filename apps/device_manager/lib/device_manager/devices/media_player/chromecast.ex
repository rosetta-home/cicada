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

  def map_state(state) do
    #Logger.info "Chromecast State #{inspect state}"
    item = case state.media_status |> Map.get("items") do
      nil -> state.media_status |> Map.get("media", %{})
      items -> items |> Enum.at(0, %{})
    end
    media = case item |> Map.get("media") do
      nil -> item
      media -> media
    end
    metadata = media |> Map.get("metadata", %{})
    images = metadata |> Map.get("images")
    image = case images do
      nil ->
        case state.media_status |> Map.get("backendData") do
          nil -> %{}
          data ->
            %{"url": Poison.decode!(data) |> Enum.at(0, "")}
        end
      i -> i |> Enum.at(0, %{})
    end
    app = Map.get(state.receiver_status, "status", %{}) |>  Map.get("applications", []) |> Enum.at(0, %{})
    #Logger.info "Media: #{inspect media}"
    %MediaPlayer.State{
      ip: state.ip |> :inet_parse.ntoa |> to_string,
      current_time:  state.media_status |> Map.get("currentTime", 0),
      content_id: media |> Map.get("content_id", 0),
      content_type: media |> Map.get("contentType", "Unknown"),
      duration: media |> Map.get("duration", 0),
      autoplay: media |> Map.get("autoplay", false),
      image: %MediaPlayer.State.Image{ url: Map.get(image, "url", Map.get(image, :url, "")) },
      title: metadata |> Map.get("title", ""),
      subtitle: metadata |> Map.get("subtitle", ""),
      volume: state.media_status |> Map.get("volume", %{}) |> Map.get("level", 0),
      status: app |> Map.get("statusText", ""),
      idle: app |> Map.get("isIdleScreen", ""),
      app_name: app |> Map.get("displayName", ""),
      id: app |> Map.get("appId")
    }
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
    device = %DeviceManager.Device{device | state:
      Chromecast.state(device.device_pid) |> map_state
    }
    device |> DeviceManager.Client.dispatch
    {:noreply, device}
  end

  def handle_call({:update, state}, _from, device) do
    {:reply, device.state, device}
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
  use DeviceManager.Discovery
  require Logger
  alias DeviceManager.Discovery
  alias DeviceManager.Device.MediaPlayer
  alias NetworkManager.State, as: NM
  alias NetworkManager.Interface, as: NMInterface

  defmodule EventHandler do
    use GenEvent
    require Logger

    def handle_event({:"_googlecast._tcp.local", device}, parent) do
        send(parent, device)
        {:ok, parent}

    end
    def handle_event(device, parent) do
      {:ok, parent}
    end

  end

  def register_callbacks do
    Logger.info "Starting Chromecast Listener"
    Mdns.EventManager.add_handler(EventHandler)
    NetworkManager.register
    {:ok, []}
  end

  def handle_info(%NM{interface: %NMInterface{settings: %{ipv4_address: address}, status: %{operstate: :up}}}, state) do
    #wait for mDNS to start, no way to guarantee who gets this event first.
    :timer.sleep(1000)
    Process.send_after(self, :query_cast, 0)
    {:noreply, state}
  end

  def handle_info(%NM{}, state) do
    {:noreply, state}
  end

  def handle_info(:query_cast, state) do
    Mdns.Client.query("_googlecast._tcp.local")
    Process.send_after(self, :query_cast, 5000)
    {:noreply, state}
  end

  def handle_info(device, state) do
    {:noreply, handle_device(device, MediaPlayer.Chromecast, state)}
  end

  def handle_info(_device, state) do
    {:noreply, state}
  end

end
