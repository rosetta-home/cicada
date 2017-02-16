defmodule DeviceManager.Device.SmartMeter do
  defmodule State do
    @derive [Poison.Encoder]
    defstruct connection_status: "",
      channel: 0,
      meter_mac_id: "",
      signal: 0,
      meter_type: "",
      price: 0,
      kw_delivered: 0,
      kw_received: 0,
      kw: 0
  end
end


defmodule DeviceManager.Discovery.SmartMeter do
  #use DeviceManager.Discovery

  alias DeviceManager.Device.SmartMeter

  def init_handlers do
    #Logger.info "Starting Raven"
    #Raven.EventManager.add_handler(Discovery.SmartMeter.RavenSMCD)
    #Hacking raven for demo
    #Process.send_after(self, {:raven, %Raven.Meter.State{
    #    id: :"0xFFFFFFFFFFFFFF",
    #    connection_status: %Raven.Message.ConnectionStatus{
    #      meter_mac_id: "0xFFFFFFFFFFFFFF",
    #      status: "Connected",
    #      channel: "22",
    #      link_strength: 100
    #    },
    #    meter_info: %Raven.Message.MeterInfo{
    #      meter_type: "electric"
    #    },
    #    price: %Raven.Message.PriceCluster{
    #      price: 0.046
    #    },
    #    summation: %Raven.Message.CurrentSummationDelivered{
    #      kw_delivered: 0,
    #      kw_received: 0
    #    },
    #    demand: %Raven.Message.InstantaneousDemand{
    #      kw: 0
    #    }
    #}}, 100)
  end

  def handle_info({:raven, %Raven.Meter.State{} = device}, state) do
    #{:noreply, handle_device(device, state, SmartMeter.RavenSMCD)}
  end

  def handle_info({:raven, %Raven.Client.State{} = _device}, state) do
    {:noreply, state}
  end

end
