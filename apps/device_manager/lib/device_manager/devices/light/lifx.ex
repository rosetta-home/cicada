defmodule DeviceManager.Device.Light.Lifx do
  use GenServer
  require Logger

  @behaviour DeviceManager.Behaviour.Light

  def start_link(id, %Lifx.Device.State{} = device) do
    GenServer.start_link(__MODULE__, {id, device}, name: id)
  end

  def on(pid) do
    GenServer.call(pid, :on)
  end

  def off(pid) do
    GenServer.call(pid, :off)
  end

  def hue(pid, hue) do
    GenServer.call(pid, {:hue, hue})
  end

  def saturation(pid, sat) do
    GenServer.call(pid, {:saturation, sat})
  end

  def brightness(pid, bright) do
    GenServer.call(pid, {:brightness, bright})
  end

  def kelvin(pid, kelvin) do
    GenServer.call(pid, {:kelvin, kelvin})
  end

  def device(pid) do
    GenServer.call(pid, :device)
  end

  def update_state(pid, state) do
    GenServer.cast(pid, {:update, state})
  end

  def get_id(device) do
    :"Lifx-#{Atom.to_string(device.id)}"
  end

  def init({id, device}) do
    {:ok, %DeviceManager.Device{
      module: Lifx.Device,
      type: :light,
      device_pid: device.id,
      interface_pid: id,
      name: device.label,
      state: device
    }}
  end

  def handle_cast({:update, state}, device) do
    {:noreply, %{device | state: state}}
  end

  def handle_call(:device, _from, device) do
    {:reply, device, device}
  end

  def handle_call(:on, _from, device) do
    Lifx.Device.on(device.pid)
    {:reply, true, device}
  end

  def handle_call(:off, _from, device) do
    Lifx.Device.off(device.device_pid)
    {:reply, true, device}
  end

  def handle_call({:hue, hue}, _from, device) do
    Lifx.Device.set_color(device.device_pid, %Lifx.Protocol.HSBK{device.state.hsbk | hue: hue})
    {:reply, true, device}
  end

  def handle_call({:saturation, sat}, _from, device) do
    Lifx.Device.set_color(device.device_pid, %Lifx.Protocol.HSBK{device.state.hsbk | saturation: sat})
    {:reply, true, device}
  end

  def handle_call({:brightness, bright}, _from, device) do
    Lifx.Device.set_color(device.device_pid, %Lifx.Protocol.HSBK{device.state.hsbk | brightness: bright})
    {:reply, true, device}
  end

  def handle_call({:kelvin, kelvin}, _from, device) do
    Lifx.Device.set_color(device.device_pid, %Lifx.Protocol.HSBK{device.state.hsbk | kelvin: kelvin})
    {:reply, true, device}
  end

end

defmodule DeviceManager.Discovery.Light.Lifx do
  use GenEvent
  require Logger

  def init do
      {:ok, []}
  end

  def handle_event(%Lifx.Device.State{} = device, parent) do
      send(parent, {:lifx, device})
      {:ok, parent}
  end

  def handle_event(_device, parent) do
      {:ok, parent}
  end

end
