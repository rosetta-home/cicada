defmodule DeviceManager.Device.SmartMeter do
  defmodule State do
    defstruct connection_status: "",
      channel: 0,
      meter_mac_id: "",
      signal: 0,
      meter_type: "",
      price: 0,
      kw_delivered: 0,
      kw_received: 0
  end
end


defmodule DeviceManager.Discovery.SmartMeter do
  use DeviceManager.Discovery

  alias DeviceManager.Device.SmartMeter

  def init_handlers do
    Logger.info "Starting Raven"
    Raven.EventManager.add_handler(Discovery.SmartMeter.RavenSMCD)
  end

  def handle_info({:raven, %Raven.Meter.State{} = device}, state) do
    {:noreply, handle_device(device, state, SmartMeter.RavenSMCD)}
  end

  def handle_info({:raven, %Raven.Client.State{} = _device}, state) do
    {:noreply, state}
  end

end
