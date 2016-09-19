defmodule DeviceManager.Device.WeatherStation.MeteoStick do
  use GenServer
  require Logger
  alias Nerves.UART, as: Serial

  @behaviour DeviceManager.Behaviour.WeatherStation

  def start_link(id, device) do
    GenServer.start_link(__MODULE__, {id, device}, name: id)
  end

  def readings(pid) do
    GenServer.call(pid, :readings)
  end

  def device(pid) do
    GenServer.call(pid, :device)
  end

  def update_state(pid, state) do
    GenServer.cast(pid, {:update, state})
  end

  def get_id(device) do
    :"MeteoStick-#{device.id}"
  end

  def init({id, device}) do
    d = %DeviceManager.Device{
      module: MeteoStick.WeatherStation,
      type: :weather_station,
      pid: String.to_atom(device.id),
      name: "Weather Station: #{device.id}",
      id: id,
      state: device
    }
    {:ok, d}
  end

  def handle_cast({:update, state}, device) do
    {:noreply, %{device | state: state}}
  end

  def handle_call(:device, _from, device) do
    {:reply, device, device}
  end

  def handle_call(:readings, _from, device) do
    {:reply, device.state, device}
  end

end

defmodule DeviceManager.Discovery.WeatherStation.MeteoStick do
  use GenEvent
  require Logger

  def init do
      {:ok, []}
  end

  def handle_event(%MeteoStick.WeatherStation.State{} = device, parent) do
      send(parent, {:meteo_stick, device})
      {:ok, parent}
  end

  def handle_event(_device, parent) do
      {:ok, parent}
  end

end
