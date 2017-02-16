defmodule Fw.Application do
  alias DeviceManager.{Discovery, Client}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    register_devices()
    children = []
    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def register_devices do
    DeviceManager.Discovery.Light.register_device(
      DeviceManager.Discovery.Light.Lifx
    )
    DeviceManager.Discovery.HVAC.register_device(
      DeviceManager.Discovery.HVAC.RadioThermostat
    )
    DeviceManager.Discovery.MediaPlayer.register_device(
      DeviceManager.Discovery.MediaPlayer.Chromecast
    )
    DeviceManager.Discovery.WeatherStation.register_device(
      DeviceManager.Discovery.WeatherStation.MeteoStick
    )
    DeviceManager.Discovery.SmartMeter.register_device(
      DeviceManager.Discovery.SmartMeter.RavenSMCD
    )
    DeviceManager.Discovery.IEQ.register_device(
      DeviceManager.Discovery.IEQ.Sensor
    )
  end
end
