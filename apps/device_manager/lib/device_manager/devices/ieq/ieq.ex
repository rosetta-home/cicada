defmodule DeviceManager.Device.IEQ do
  defmodule State do
    @derive [Poison.Encoder]
    defstruct id: 0,
      battery: 0,
      co2: 0,
      door: 0,
      energy: 0,
      pressure: 0,
      humidity: 0,
      light: 0,
      motion: 0,
      no2: 0,
      co: 0,
      pm: 0,
      rssi: 0,
      sound: 0,
      temperature: 0,
      uv: 0,
      voc: 0
  end
end

defmodule DeviceManager.Discovery.IEQ do
  #use DeviceManager.Discovery

  alias DeviceManager.Device.IEQ

  def init_handlers do
    #Logger.info "Starting IEQ"
    IEQGateway.EventManager.add_handler(Discovery.IEQ.Sensor)
  end

  def handle_info({:ieq_sensor, device}, state) do
    #{:noreply, handle_device(device, state, IEQ.Sensor)}
  end

end
