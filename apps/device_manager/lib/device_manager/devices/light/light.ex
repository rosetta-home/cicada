defmodule DeviceManager.Discovery.Light do
  use DeviceManager.Discovery

  alias DeviceManager.Device.Light
  alias DeviceManager.Discovery

  def init_handlers do
    Logger.info "Starting Lifx Listener"
    Lifx.Client.add_handler(Discovery.Light.Lifx)
  end

  def handle_info({:lifx, device}, state) do
    {:noreply, handle_device(device, state, Light.Lifx)}
  end

end
