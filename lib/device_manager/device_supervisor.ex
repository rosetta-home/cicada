defmodule Cicada.DeviceManager.DeviceSupervisor do
  use Supervisor

  def start_link(module) do
    Supervisor.start_link(__MODULE__, module, name: :"#{module}.Supervisor")
  end

  def init(module) do
    children = [worker(module, [], restart: :temporary)]
    supervise(children, strategy: :simple_one_for_one)
  end
end
