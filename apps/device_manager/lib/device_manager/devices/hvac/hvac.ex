defmodule DeviceManager.Discovery.HVAC do
  use DeviceManager.Discovery

  alias DeviceManager.Device.HVAC
  alias DeviceManager.Discovery

  def init_handlers do
    Logger.info "Starting Radio Thermostat Listener"
    SSDP.Client.add_handler(Discovery.HVAC.RadioThermostat)
  end

  def handle_info({:radio_thermostat, device}, state) do
    {:noreply, handle_device(device, state, HVAC.RadioThermostat)}
  end

end
