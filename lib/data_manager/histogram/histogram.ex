defmodule Cicada.DataManager.Histogram do
  use Supervisor
  require Logger
  alias Cicada.DataManager.Histogram
  alias Cicada.DeviceManager

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def snapshot() do
    Enum.reduce(Supervisor.which_children(__MODULE__), [], fn({_id, child, _type, _module}, acc) ->
      values = Histogram.Device.snapshot(child)
      name = Process.info(child)[:registered_name]
      case Registry.lookup(Cicada.DataManager.Registry, name) do
        [{_pid, {device, pid}} | tail] -> [%{device: device,  values: values}] ++ acc
        [] -> []
      end
    end)
  end

  def reset() do
    Enum.each(Supervisor.which_children(__MODULE__), fn {_id, child, _type, _module} ->
      Histogram.Device.Record.reset(child)
    end)
  end

  def start_device(id, %DeviceManager.Device{} = device) do
    case Supervisor.start_child(__MODULE__, [id]) do
      {:error, {:already_started, _}} -> :already_started
      {:ok, pid} ->
        Registry.register(Cicada.DataManager.Registry, id, {device, pid})
        Logger.debug "Device #{id} Started"
        {:ok, pid}
    end
  end

  def init(:ok) do
    Logger.info "Starting Histogram Device"
    children = [
      worker(Histogram.Device, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
