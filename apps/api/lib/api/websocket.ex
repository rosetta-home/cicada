defmodule API.Websocket do
  @behaviour :cowboy_websocket_handler
  require Logger

  defmodule State do
    defstruct [:user_id, devices: []]
  end

  def init({tcp, http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_TransportName, req, _opts) do
    {user_id, req} = :cowboy_req.qs_val("user_id", req)
    Process.send_after(self, :heartbeat, 1000)
    API.DeviceConsumer.start_link(self)
    API.DataConsumer.start_link(self)
    {:ok, req, %State{user_id: user_id}}
  end

  def websocket_terminate(_reason, _req, state) do
    Logger.info "Terminating Websocket #{state.user_id}"
    :ok
  end

  def websocket_handle({:text, data}, req, state) do
    cmd = Poison.decode!(data)
    case cmd["type"] do
      "LightColor" ->
        Logger.info "Got LightColor"
        i_pid = String.to_existing_atom(cmd["payload"]["id"])
        DeviceManager.Device.Light.Lifx.color(i_pid, cmd["payload"]["h"], cmd["payload"]["s"], cmd["payload"]["v"])
      "LightPower" ->
          Logger.info "Got LightPower"
          i_pid = String.to_existing_atom(cmd["id"])
          case cmd["payload"] do
            true -> DeviceManager.Device.Light.Lifx.on(i_pid)
            false -> DeviceManager.Device.Light.Lifx.off(i_pid)
          end
    end
    {:reply, {:text, "ok"}, req, state}
  end

  def websocket_handle(_data, req, state) do
    {:ok, req, state}
  end

  def handle_message(message = %{}, state) do
    IO.inspect message
    Logger.info "Sending to: #{message.id}"
    send(message.id, message)
    state
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
    #{:reply, {:text, Poison.encode!(event)}, req, state}
  end

  def websocket_info(_info, req, state) do
    {:ok, req, state}
  end

  def device_name(device) do
    case device.name do
      "" -> "Unknown"
      _ ->
        Logger.info("Light Name: #{device.name}")
        "Unknown"
    end
  end

end
