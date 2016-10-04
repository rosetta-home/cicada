defmodule DeviceManager.Device.WeatherStation.MeteoStick do
  use GenServer
  require Logger

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
    GenServer.call(pid, {:update, state})
  end

  def get_id(device) do
    :"MeteoStick-#{Atom.to_string(device.id)}"
  end

  def map_state(state) do
    state = Map.merge(%DeviceManager.Device.WeatherStation.State{}, state)
    state
  end

  def init({id, device}) do
    {:ok, %DeviceManager.Device{
      module: MeteoStick.WeatherStation,
      type: :weather_station,
      device_pid: device.id,
      interface_pid: id,
      name: Atom.to_string(device.id),
      state: device |> map_state
    }}
  end

  def handle_call({:update, state}, _from, device) do
    state = state |> map_state
    {:reply, state, %DeviceManager.Device{device | state: state}}
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
