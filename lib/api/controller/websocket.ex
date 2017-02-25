defmodule Cicada.API.Controller.Websocket do
  @behaviour :cowboy_websocket_handler
  alias Cicada.{DeviceManager, SysMon}
  require Logger

  defmodule State do
    defstruct temp_debounce: %{}
  end

  def init({_tcp, _http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_TransportName, req, _opts) do
    DeviceManager.register
    SysMon.register
    {:ok, req, %State{}}
  end

  def websocket_terminate(reason, _req, _state) do
    IO.inspect reason
    :ok
  end

  def websocket_handle({:text, data}, req, state) do
    cmd = Poison.decode!(data)
    state = case cmd["type"] do
      "LightColor" ->
        Logger.info "Got LightColor"
        i_pid = String.to_existing_atom(cmd["payload"]["id"])
        DeviceManager.Device.Light.Lifx.color(i_pid, cmd["payload"]["h"], cmd["payload"]["s"], cmd["payload"]["v"])
        state
      "LightPower" ->
        Logger.info "Got LightPower"
        i_pid = String.to_existing_atom(cmd["id"])
        case cmd["payload"] do
          true -> DeviceManager.Device.Light.Lifx.on(i_pid)
          false -> DeviceManager.Device.Light.Lifx.off(i_pid)
        end
        state
      "Temperature" ->
        i_pid = String.to_existing_atom(cmd["id"])
        temp = case Float.parse cmd["payload"] do
          {num, _rem} -> num
          :error -> 72
        end
        case Map.get(state.temp_debounce, i_pid) do
          nil ->
            Process.send_after(self(), {:send_temp, i_pid}, 1000)
            %State{state | temp_debounce: Map.put(state.temp_debounce, i_pid, temp)}
          _val ->
            db = Map.update!(state.temp_debounce, i_pid, fn(_v) -> temp end)
            %State{state | temp_debounce: db}
        end
    end
    {:reply, {:text, "ok"}, req, state}
  end

  def websocket_handle(_data, req, state) do
    {:ok, req, state}
  end

  def websocket_info({:send_temp, pid}, req, state) do
    temp = Map.get(state.temp_debounce, pid)
    Logger.info "Setting Temp: #{inspect pid} = #{temp}"
    DeviceManager.Device.HVAC.RadioThermostat.set_temp(pid, temp)
    state = %State{ state | temp_debounce: Map.delete(state.temp_debounce, pid)}
    {:ok, req, state}
  end

  def websocket_info(%DeviceManager.Device{} = event, req, state) do
    #Logger.info "Process: #{inspect Process.info(self, :message_queue_len)}"
    event = %DeviceManager.Device{event | device_pid: ""}
    {:reply, {:text, Poison.encode!(event)}, req, state}
  end

  def websocket_info(%SysMon.Cpu{} = event, req, state) do
    ws_event = %{
      type: "cpu",
      state: event,
      name: "CPU #{event.cpu}",
      module: "SysMon.Cpu",
      interface_pid: "sys_mon-cpu-#{event.cpu}",
      device_pid: ""
    }
    {:ok, data} = Poison.encode(ws_event)
    {:reply, {:text, data}, req, state}
  end

  def websocket_info(%SysMon.Memory{} = event, req, state) do
    ws_event = %{
      type: "memory",
      state: event,
      name: "Memory",
      module: "SysMon.Memory",
      interface_pid: "sys_mon-memory",
      device_pid: ""
    }
    {:ok, data} = Poison.encode(ws_event)
    {:reply, {:text, data}, req, state}
  end

  def websocket_info(_info, req, state) do
    {:ok, req, state}
  end

end
