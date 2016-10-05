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

  def map_state(state) do
    %DeviceManager.Device.SmartMeter.State{
      connection_status: state.connection_status.status,
      channel: state.connection_status.channel,
      meter_mac_id: state.connection_status.meter_mac_id,
      signal: state.connection_status.link_strength,
      meter_type: state.meter_info.meter_type,
      price: state.price.price,
      kw_delivered: state.summation.kw_delivered,
      kw_received: state.summation.kw_received,
      kw: state.demand.kw
    }
  end

  def init({id, device}) do
    #Process.send_after(self, :fake_data, 1000)
    {:ok, %DeviceManager.Device{
      module: Raven.Client,
      type: :smart_meter,
      device_pid: device.id,
      interface_pid: id,
      name: "Raven - #{Atom.to_string(device.id)}",
      state: device |> map_state
    }}
  end

  def handle_info(:fake_data, device) do
    Process.send_after(self, :fake_data, 1000)
    kw = :rand.uniform()
    kw_r = device.state.kw_received + kw
    kw_d = device.state.kw_delivered + kw
    device = %DeviceManager.Device{device | state: %{ device.state | kw_received: kw_r, kw_delivered: kw_d, kw: kw} }
    DeviceManager.Broadcaster.sync_notify(device)
    {:noreply, device}
  end

  def handle_call({:update, state}, _from, device) do
    state = state |> map_state
    {:reply, state, %DeviceManager.Device{device | state: state}}
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
