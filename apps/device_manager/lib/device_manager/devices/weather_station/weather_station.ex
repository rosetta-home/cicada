defmodule DeviceManager.Device.WeatherStation do
  defmodule State do
    defstruct id: 0,
      outdoor_temperature: 0,
      indoor_temperature: 0,
      humidity: 0,
      pressure: 0,
      wind: %{
        speed: 0,
        direction: 0,
        gust: 0
      },
      rain: 0,
      uv: 0,
      solar: %{
        radiation: 0,
        intensity: 0
      }
    end
end

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
