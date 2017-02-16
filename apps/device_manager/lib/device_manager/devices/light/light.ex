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
end
