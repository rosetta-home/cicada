defmodule DeviceManager do
  use Application
  require Logger

  defmodule Device do
    defstruct module: nil,
      type: nil,
      device_pid: nil,
      interface_pid: nil,
      name: "",
      state: %{}
  end

  def start(_type, _args) do
    DeviceManager.BroadcastSupervisor.start_link
  end

end
