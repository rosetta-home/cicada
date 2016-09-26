defmodule DeviceManager.Device.HVAC.RadioThermostat do
  use GenServer
  require Logger

  @behaviour DeviceManager.Behaviour.HVAC

  def start_link(id, %{device: %{device_type: "com.marvell.wm.system:1.0"}} = device) do
    GenServer.start_link(__MODULE__, {id, device}, name: id)
  end

  def fan_on(pid) do
    GenServer.call(pid, :on)
  end

  def fan_off(pid) do
    GenServer.call(pid, :off)
  end

  @spec set_temp(pid, number) :: boolean
  def set_temp(pid, temp) do
    GenServer.call(pid, {:set_temp, temp})
  end

  def device(pid) do
    GenServer.call(pid, :device)
  end

  def update_state(pid, state) do
    GenServer.call(pid, {:update, state})
  end

  def get_id(device) do
    :"RadioThermostat-#{device.device.serial_number}"
  end

  def map_state({:ok, state}) do
    %DeviceManager.Device.HVAC.State{
      temperature: state["temp"],
      fan_mode: state["fmode"] |> fmode,
      fan_state: state["fstate"] |> fstate,
      temporary_target_cool: state |> Map.get("t_cool", 0),
      temporary_target_heat: state |> Map.get("t_heat", 0),
      mode: state["tmode"] |> tmode,
      state: state["tstate"] |> tstate,
    }
  end

  def tstate(val) do
    case val do
      0 -> :off
      1 -> :heat
      2 -> :cool
    end
  end

  def tmode(val) do
    case val do
      0 -> :off
      1 -> :heat
      2 -> :cool
      3 -> :auto
    end
  end

  def fmode(val) do
    case val do
      0 -> :auto
      1 -> :auto_circulate
      2 -> :on
    end
  end

  def fstate(val) do
    case val do
      0 -> :off
      1 -> :on
    end
  end

  def init({id, device}) do
    {:ok, pid} = RadioThermostat.start_link(device.url)
    Process.send_after(self, :update_state, 1000)
    r_state = RadioThermostat.state(pid)
    {:ok, %DeviceManager.Device{
      module: RadioThermostat,
      type: :hvac,
      device_pid: pid,
      interface_pid: id,
      name: device.device.friendly_name,
      state: r_state
    }}
  end

  def handle_info(:update_state, device) do
    device = %DeviceManager.Device{device | state:
      RadioThermostat.state(device.device_pid) |> map_state
    }
    Process.send_after(self, :update_state, 10000)
    DeviceManager.Broadcaster.sync_notify(device)
    {:noreply, device}
  end

  def handle_call({:update, state}, _from, device) do
    {:reply, device.state, device}
  end

  def handle_call(:device, _from, device) do
    {:reply, device, device}
  end

  def handle_call(:on, _from, state) do
    {:reply,
      case RadioThermostat.set(state.device_pid, :fan, 1) do
        {:ok, %{"success": 0}} -> true
        other ->
          IO.inspect other
          false
      end, state}
  end

  def handle_call(:off, _from, state) do
    {:reply,
      case RadioThermostat.set(state.device_pid, :fan, 0) do
        {:ok, %{"success": 0}} -> true
        other ->
          IO.inspect other
          false
      end, state}
  end

  def handle_call({:set_temp, temp}, _from, state) do
    {:reply,
      case RadioThermostat.set(state.device_pid, :temporary_cool, temp) do
        {:ok, %{"success": 0}} -> true
        _other ->
          false
      end, state}
  end

end

defmodule DeviceManager.Discovery.HVAC.RadioThermostat do
  use GenEvent
  require Logger

  def init do
      {:ok, []}
  end

  def handle_event({:device, %{device: %{device_type: "com.marvell.wm.system:1.0"}} = device}, parent) do
      send(parent, {:radio_thermostat, device})
      {:ok, parent}
  end

  def handle_event(_device, parent) do
      {:ok, parent}
  end

end
