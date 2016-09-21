defmodule DeviceManager.Discovery.IEQ do
  use DeviceManager.Discovery

  alias DeviceManager.Device.IEQ

  def init_handlers do
    Logger.info "Starting IEQ"
    IEQGateway.EventManager.add_handler(Discovery.IEQ.Sensor)
  end

  def handle_info({:ieq_sensor, device}, state) do
    {:noreply, handle_device(device, state, IEQ.Sensor)}
  end

end
