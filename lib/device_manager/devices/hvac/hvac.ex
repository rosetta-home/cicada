defmodule Cicada.DeviceManager.Device.HVAC do

  @on_off %{:on => 2, :off => 1}
  @hold %{:on => 1, :off => 0}
  @tmode %{:off => 0, :heat => 1, :cool => 2, :auto => 3}
  @fmode %{:auto => 0, :auto_circulate => 1, :on => 2}
  @tstate %{:off => 0, :heat => 1, :cool => 2}

  defmodule State do
    @derive [Poison.Encoder]
    defstruct temperature: 0,
      fan_mode: :off,
      fan_state: :off,
      temporary_target_cool: 0,
      temporary_target_heat: 0,
      mode: :auto,
      state: :off
  end
end
