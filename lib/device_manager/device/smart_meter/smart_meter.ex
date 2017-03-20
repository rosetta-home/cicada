defmodule Cicada.DeviceManager.Device.SmartMeter do

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
