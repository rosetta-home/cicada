defmodule DeviceManager.Device.Light do

  defmodule State.HSBK do
    @derive [Poison.Encoder]
    defstruct hue: 120,
      saturation: 100,
      brightness: 100,
      kelvin: 4000
  end

  defmodule State do
    @derive [Poison.Encoder]
    defstruct host: "0.0.0.0",
      port: 57600,
      label: "",
      power: 0,
      signal: 0,
      rx: 0,
      tx: 0,
      hsbk: %State.HSBK{},
      group: "",
      location: ""
  end
end

defmodule DeviceManager.Discovery.Light do
  use DeviceManager.Discovery

  alias DeviceManager.Device.Light
  alias DeviceManager.Discovery

  def init_handlers do
    Logger.info "Starting Lifx Listener"
    Lifx.Client.add_handler(Discovery.Light.Lifx)
  end

  def handle_info({:lifx, device}, state) do
    {:noreply, handle_device(device, state, Light.Lifx)}
  end

end
