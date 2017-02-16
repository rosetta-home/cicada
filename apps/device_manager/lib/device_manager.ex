defmodule DeviceManager do

  defmodule Device do
    @derive [Poison.Encoder]
    defstruct module: nil,
      type: nil,
      device_pid: nil,
      interface_pid: nil,
      name: "",
      state: %{}
  end

  def register do
    GenServer.call(DeviceManager.Client, :register)
  end

end
