defmodule DeviceManager.Device.MediaPlayer do
  defmodule State do
    defstruct ip: "0.0.0.0",
      media_status: %{
        current_time: 0,
        items: [] #Item
      },
      receiver_status: %{
        volume: 0,
        applications: [] #Application
      }
  end

  defmodule State.Image do
    defstruct url: "",
      width: 0,
      height: 0
  end

  defmodule State.Item do
    defstruct autoplay: False,
      id: nil,
      content_id: nil,
      content_type: "",
      type: "",
      duration: 0,
      images: [], #Image
      title: "",
      subtitle: ""
  end

  defmodule State.Application do
    defstruct id: nil,
      name: "",
      idle: False,
      session_id: "",
      status: ""
  end
end

defmodule DeviceManager.Discovery.MediaPlayer do
  use DeviceManager.Discovery

  alias DeviceManager.Device.MediaPlayer

  def init_handlers do
    Logger.info "Starting Chromecast"
    Mdns.Client.add_handler(Discovery.MediaPlayer.Chromecast)
    Mdns.Client.start
    Process.send_after(self, :query_cast, 100)
  end

  def handle_info({:googlecast, device}, state) do
    {:noreply, handle_device(device, state, MediaPlayer.Chromecast)}
  end

  def handle_info(:query_cast, state) do
    Mdns.Client.query("_googlecast._tcp.local")
    Process.send_after(self, :query_cast, 5000)
    {:noreply, state}
  end

end
