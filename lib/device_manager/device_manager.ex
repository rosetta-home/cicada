defmodule Cicada.DeviceManager do

  defmodule Device do
    @derive [Poison.Encoder]
    defstruct module: nil,
      type: nil,
      device_pid: nil,
      interface_pid: nil,
      histogram: nil,
      name: "",
      state: %{}
  end

  def register do
    Cicada.DeviceManager.Client |> GenServer.call(:register)
  end

  def dispatch(event) do
    DeviceManager |> Cicada.EventManager.dispatch(event)
  end

  def devices do
    Cicada.DeviceManager.DiscoverySupervisor
    |> Supervisor.which_children
    |> Enum.flat_map(fn {_id, child, _type, [module | _ta] = _modules} ->
      module.devices(child)
    end)
  end

  def handle_call(:register, {pid, _ref}, state) do
    Registry.register(EventManager.Registry, DeviceManager, pid)
    {:reply, :ok, state}
  end

  def register_plugins(plugins) do
    Cicada.DeviceManager.Supervisor |> Supervisor.start_child([plugins])
  end

end
