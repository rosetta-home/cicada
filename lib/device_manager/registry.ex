defmodule Cicada.DeviceManager.Registry do

  def start(discovery) do
    Cicada.DeviceManager.ClientSupervisor |> Supervisor.start_child([discovery])
  end
end
