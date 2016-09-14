defmodule DeviceManager.Discovery.WeatherStation do
  use DeviceManager.Discovery

  alias DeviceManager.Device.WeatherStation

  def init_handlers do
    Logger.info "Starting MeteoStick"
    MeteoStick.EventManager.add_handler(Discovery.WeatherStation.MeteoStick)
  end

  def handle_info({:meteo_stick, device}, state) do
    {:noreply, handle_device(device, state, WeatherStation.MeteoStick)}
  end

end
