defmodule DeviceManager.Device.MediaPlayer do

  defmodule State.Image do
    @derive [Poison.Encoder]
    defstruct url: "",
      width: 0,
      height: 0
  end

  defmodule State do
    @derive [Poison.Encoder]
    defstruct ip: "0.0.0.0",
      current_time: 0,
      content_id: "",
      content_type: "",
      duration: 0,
      autoplay: false,
      image: %State.Image{},
      title: "",
      subtitle: "",
      volume: 0,
      status: "",
      idle: False,
      app_name: "",
      id: ""
  end
end

defmodule DeviceManager.Discovery.MediaPlayer do
  use DeviceManager.Discovery
end
