defmodule API.Websocket do
  @behaviour :cowboy_websocket_handler
  require Logger

  defmodule State do
    defstruct user_id: nil,
      devices: [],
      temp_debounce: %{}
  end

  def init({tcp, http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_TransportName, req, _opts) do
    {user_id, req} = :cowboy_req.qs_val("user_id", req)
    Process.send_after(self, :heartbeat, 1000)
    API.DeviceConsumer.start_link(self)
    #API.DataConsumer.start_link(self)
    {:ok, req, %State{user_id: user_id}}
  end

  def websocket_terminate(reason, _req, state) do
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
        Logger.info "Got Temperature Adjustment"
        temp = case Float.parse cmd["payload"] do
          {num, rem} -> num
          :error -> 72
        end
        case Map.get(state.temp_debounce, i_pid) do
          nil ->
            Logger.info("New Setting")
            Process.send_after(self, {:send_temp, i_pid}, 1000)
            %State{state | temp_debounce: Map.put(state.temp_debounce, i_pid, temp)}
          val ->
            Logger.info("OLD Setting: #{val}")
            db = Map.update!(state.temp_debounce, i_pid, fn(v) ->
              Logger.info "Updating Key: #{v}"
              temp
            end)
            %State{state | temp_debounce: db}
        end
    end
    Logger.info "#{inspect state}"
    {:reply, {:text, "ok"}, req, state}
  end

  def websocket_handle(_data, req, state) do
    {:ok, req, state}
  end

  def websocket_info({:send_temp, pid}, req, state) do
    Logger.info "Trying to set temp"
    temp = Map.get(state.temp_debounce, pid)
    Logger.info "Setting Temp: #{inspect pid} = #{temp}"
    DeviceManager.Device.HVAC.RadioThermostat.set_temp(pid, temp)
    state = %State{ state | temp_debounce: Map.delete(state.temp_debounce, pid)}
    {:ok, req, state}
  end

  def websocket_info(:heartbeat, req, state) do
    Process.send_after(self, :heartbeat, 1000)
    {:reply, {:text, Poison.encode!(%{type: :heartbeat})}, req, state}
  end

  def websocket_info({:device_event, %DeviceManager.Device{} = event}, req, state) do
    event = %DeviceManager.Device{event | device_pid: ""}
    {:reply, {:text, Poison.encode!(event)}, req, state}
  end

  def websocket_info({:device_event, event}, req, state) do
    {:ok, req, state}
  end

  def websocket_info({:data_event, %{} = event}, req, state) do
    {:ok, req, state}
  end

  def websocket_info(_info, req, state) do
    {:ok, req, state}
  end

end
