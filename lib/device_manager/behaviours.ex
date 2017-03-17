defmodule Cicada.DeviceManager.Behaviour.Device do
  alias Cicada.DeviceManager.Device
  @callback get_id(map) :: atom
  @callback start_link(atom, map) :: {atom, pid}
  @callback device(pid) :: %Device{}
  @callback update_state(pid, map) :: %Device{}
end

defmodule Cicada.DeviceManager.Behaviour.IEQ do
  @behaviour Cicada.DeviceManager.Behaviour.Device
  @callback readings(pid) :: map
end

defmodule Cicada.DeviceManager.Behaviour.Camera do
  @behaviour Cicada.DeviceManager.Behaviour.Device
  @callback image(pid) :: <<>>
  @callback pan(pid, integer) :: boolean
  @callback zoom(pid, integer) :: boolean
end

defmodule Cicada.DeviceManager.Behaviour.HVAC do
  @behaviour Cicada.DeviceManager.Behaviour.Device
  @callback fan_on(pid) :: boolean
  @callback fan_off(pid) :: boolean
  @callback set_temp(pid, number) :: boolean
end

defmodule Cicada.DeviceManager.Behaviour.Light do
  @behaviour Cicada.DeviceManager.Behaviour.Device
  @callback on(pid) :: boolean
  @callback off(pid) :: boolean
  @callback hue(pid, integer) :: boolean
  @callback saturation(pid, integer) :: boolean
  @callback brightness(pid, integer) :: boolean
  @callback kelvin(pid, integer) :: boolean
end

defmodule Cicada.DeviceManager.Behaviour.LoadController do
  @behaviour Cicada.DeviceManager.Behaviour.Device
  @callback on(pid) :: boolean
  @callback off(pid) :: boolean
  @callback demand(pid) :: integer
end

defmodule Cicada.DeviceManager.Behaviour.MediaPlayer do
  @behaviour Cicada.DeviceManager.Behaviour.Device
  @callback play(pid, String.t) :: boolean
  @callback pause(pid) :: boolean
  @callback set_volume(pid, float) :: boolean
  @callback status(pid) :: map
end

defmodule Cicada.DeviceManager.Behaviour.SmartMeter do
  @behaviour Cicada.DeviceManager.Behaviour.Device
  @callback demand(pid) :: number
  @callback produced(pid) :: number
  @callback consumed(pid) :: number
  @callback price(pid) :: number
end

defmodule Cicada.DeviceManager.Behaviour.WeatherStation do
  @behaviour Cicada.DeviceManager.Behaviour.Device
  @callback readings(pid) :: map
end
