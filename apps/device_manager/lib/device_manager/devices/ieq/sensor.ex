defmodule DeviceManager.Device.IEQ.Sensor do
  use GenServer
  require Logger

  @behaviour DeviceManager.Behaviour.IEQ

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
    :"Sensor-#{device.id}"
  end

  def init({id, device}) do
    {:ok, %DeviceManager.Device{
      module: IEQGateway.IEQStation,
      type: :ieq,
      device_pid: device.id,
      interface_pid: id,
      name: Atom.to_string(device.id),
      state: device
    }}
  end

  def handle_call({:update, state}, _from, device) do
    device = %{device | state: state}
    {:reply, device, device}
  end

  def handle_call(:device, _from, device) do
    {:reply, device, device}
  end

  def handle_call(:readings, _from, device) do
    {:reply, device.state, device}
  end

end

defmodule DeviceManager.Discovery.IEQ.Sensor do
  use GenEvent
  require Logger

  def init do
      {:ok, []}
  end

  def handle_event(%IEQGateway.IEQStation.State{} = device, parent) do
      send(parent, {:ieq_sensor, device})
      {:ok, parent}
  end

  def handle_event(_device, parent) do
      {:ok, parent}
  end

end
