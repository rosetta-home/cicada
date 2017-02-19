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

  def color(pid, hue, saturation, brightness) do
    GenServer.call(pid, {:color, hue, saturation, brightness})
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
    GenServer.call(pid, {:update, state})
  end

  def get_id(device) do
    :"Lifx-#{Atom.to_string(device.id)}"
  end

  def hue(hsbk), do: round((hsbk.hue/65535) * 360)
  def saturation(hsbk), do: round((hsbk.saturation/65535) * 100)
  def brightness(hsbk), do: round((hsbk.brightness/65535) * 100)

  def map_state(state) do
    %DeviceManager.Device.Light.State{
      host: state.host |> :inet_parse.ntoa |> to_string,
      port: state.port,
      label: state.label,
      power: state.power,
      signal: state.signal,
      rx: state.rx,
      tx: state.tx,
      hsbk: %DeviceManager.Device.Light.State.HSBK{
        hue: state.hsbk |> hue,
        saturation: state.hsbk  |> saturation,
        brightness: state.hsbk  |> brightness,
        kelvin: state.hsbk.kelvin
      },
      group: state.group.label,
      location: state.location.label
    }
  end

  def init({id, device}) do
    Process.send_after(self(), :add_voice_controls, 100)
    {:ok, %DeviceManager.Device{
      module: Lifx.Device,
      type: :light,
      device_pid: device.id,
      interface_pid: id,
      name: device.label,
      state: device |> map_state
    }}
  end

  def handle_info(:add_voice_controls, device) do
    VoiceControl.Client.add_handler("TURN LIGHTS ON", 1)
    VoiceControl.Client.add_handler("TURN LIGHTS OFF", 2)
    {:noreply, device}
  end

  def handle_info({:voice_callback, 1}, device) do
    Logger.info "Got Callback 1"
    Lifx.Device.on(device.device_pid)
    {:noreply, device}
  end

  def handle_info({:voice_callback, 2}, device) do
    Logger.info "Got Callback 2"
    Lifx.Device.off(device.device_pid)
    {:noreply, device}
  end

  def handle_call({:update, state}, _from, device) do
    state = state |> map_state
    {:reply, state, %DeviceManager.Device{device | name: device.state.label, state: state}}
  end

  def handle_call(:device, _from, device) do
    {:reply, device, device}
  end

  def handle_call(:on, _from, device) do
    Lifx.Device.on(device.device_pid)
    {:reply, true, device}
  end

  def handle_call(:off, _from, device) do
    Lifx.Device.off(device.device_pid)
    {:reply, true, device}
  end

  def handle_call({:color, hue, sat, bri}, _from, device) do
    Lifx.Device.set_color(
      device.device_pid,
      %Lifx.Protocol.HSBK{hue: hue, saturation: sat, brightness: bri, kelvin: device.state.hsbk.kelvin},
      200
    )
    {:reply, true, device}
  end

  def handle_call({:hue, hue}, _from, device) do
    Lifx.Device.set_color(device.device_pid, %Lifx.Protocol.HSBK{device.state.hsbk | hue: hue}, 200)
    {:reply, true, device}
  end

  def handle_call({:saturation, sat}, _from, device) do
    Lifx.Device.set_color(device.device_pid, %Lifx.Protocol.HSBK{device.state.hsbk | saturation: sat}, 200)
    {:reply, true, device}
  end

  def handle_call({:brightness, bright}, _from, device) do
    Lifx.Device.set_color(device.device_pid, %Lifx.Protocol.HSBK{device.state.hsbk | brightness: bright}, 200)
    {:reply, true, device}
  end

  def handle_call({:kelvin, kelvin}, _from, device) do
    Lifx.Device.set_color(device.device_pid, %Lifx.Protocol.HSBK{device.state.hsbk | kelvin: kelvin}, 200)
    {:reply, true, device}
  end

end

defmodule DeviceManager.Discovery.Light.Lifx do
  use DeviceManager.Discovery
  require Logger
  alias DeviceManager.Device.Light

  defmodule EventHandler do
    use GenEvent
    require Logger

    def handle_event(%Lifx.Device.State{} = device, parent) do
      send(parent, device)
      {:ok, parent}
    end

    def handle_event(_device, parent) do
      {:ok, parent}
    end

  end

  def register_callbacks do
    Logger.info "Starting Lifx Listener"
    Lifx.Client.add_handler(EventHandler)
    {:ok, []}
  end

  def handle_info(%Lifx.Device.State{} = device, state) do
    {:noreply, handle_device(device, Light.Lifx, state)}
  end

  def handle_info(_device, state) do
    {:noreply, state}
  end

end
