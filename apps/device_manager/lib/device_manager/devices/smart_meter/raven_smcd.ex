defmodule DeviceManager.Device.SmartMeter.RavenSMCD do
  use GenServer
  require Logger

  @behaviour DeviceManager.Behaviour.SmartMeter

  def start_link(id, device) do
    GenServer.start_link(__MODULE__, {id, device}, name: id)
  end

  def demand(pid) do
    GenServer.call(pid, :demand)
  end

  def produced(pid) do
    GenServer.call(pid, :produced)
  end

  def consumed(pid) do
    GenServer.call(pid, :consumed)
  end

  def price(pid) do
    GenServer.call(pid, :consumed)
  end

  def device(pid) do
    GenServer.call(pid, :device)
  end

  def update_state(pid, state) do
    GenServer.call(pid, {:update, state})
  end

  def get_id(device) do
    :"RavenSMCD-#{Atom.to_string(device.id)}"
  end

  def init({id, device}) do
    {:ok, %DeviceManager.Device{
      module: Raven.Client,
      type: :smart_meter,
      device_pid: device.id,
      interface_pid: id,
      name: "Raven - #{Atom.to_string(device.id)}",
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

  def handle_call(:demand, _from, device) do
    Raven.Client.get_demand(device.device_pid)
    {:reply, 300, device}
  end

  def handle_call(:produced, _from, device) do
    Raven.Client.get_summation(device.device_pid)
    {:reply, 300, device}
  end

  def handle_call(:consumed, _from, device) do
    Raven.Client.get_summation(device.device_pid)
    {:reply, 300, device}
  end

  def handle_call(:price, _from, device) do
    Raven.Client.get_price(device.device_pid)
    {:reply, 300, device}
  end

end

defmodule DeviceManager.Discovery.SmartMeter.RavenSMCD do
  use GenEvent
  require Logger

  def init(parent) do
      {:ok, parent}
  end

  def handle_event(message, parent) do
      send(parent, {:raven, message})
      {:ok, parent}
  end
end