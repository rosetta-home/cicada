defmodule Fw.Application do
  alias DeviceManager.Discovery

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    register_devices()
    children = []
    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def register_devices do
    Discovery.Light.register_device(Discovery.Light.Lifx)
    Discovery.HVAC.register_device(Discovery.HVAC.RadioThermostat)
    Discovery.MediaPlayer.register_device(Discovery.MediaPlayer.Chromecast)
    Discovery.WeatherStation.register_device(Discovery.WeatherStation.MeteoStick)
    Discovery.SmartMeter.register_device(Discovery.SmartMeter.RavenSMCD)
    Discovery.IEQ.register_device(Discovery.IEQ.Sensor)
  end
end
