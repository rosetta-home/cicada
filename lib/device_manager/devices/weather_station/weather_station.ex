defmodule Cicada.DeviceManager.Device.WeatherStation do
  defmodule State do
    @derive [Poison.Encoder]
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
