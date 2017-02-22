defmodule Cicada.DeviceManager.Behaviour.IEQ do
  @callback readings(pid) :: %{}
end

defmodule Cicada.DeviceManager.Behaviour.Camera do
  @callback image(pid) :: <<>>
  @callback pan(pid, integer) :: boolean
  @callback zoom(pid, integer) :: boolean
end

defmodule Cicada.DeviceManager.Behaviour.HVAC do
  @callback fan_on(pid) :: boolean
  @callback fan_off(pid) :: boolean
  @callback set_temp(pid, number) :: boolean
end

defmodule Cicada.DeviceManager.Behaviour.Light do
  @callback on(pid) :: boolean
  @callback off(pid) :: boolean
  @callback hue(pid, integer) :: boolean
  @callback saturation(pid, integer) :: boolean
  @callback brightness(pid, integer) :: boolean
  @callback kelvin(pid, integer) :: boolean
end

defmodule Cicada.DeviceManager.Behaviour.LoadController do
  @callback on(pid) :: boolean
  @callback off(pid) :: boolean
  @callback demand(pid) :: integer
end

defmodule Cicada.DeviceManager.Behaviour.MediaPlayer do
  @callback play(pid, String.t) :: boolean
  @callback pause(pid) :: boolean
  @callback set_volume(pid, float) :: boolean
  @callback status(pid) :: %{}
end

defmodule Cicada.DeviceManager.Behaviour.SmartMeter do
  @callback demand(pid) :: number
  @callback produced(pid) :: number
  @callback consumed(pid) :: number
  @callback price(pid) :: number
end

defmodule Cicada.DeviceManager.Behaviour.WeatherStation do
  @callback readings(pid) :: %{}
end
