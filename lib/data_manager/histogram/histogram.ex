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
      [{_pid, device} | tail] = Registry.lookup(Cicada.DataManager.Registry, name)
      [%{device: device,  values: values}] ++ acc
    end)
  end

  def reset() do
    Enum.each(Supervisor.which_children(__MODULE__), fn {_id, child, _type, _module} ->
      Histogram.Device.Record.reset(child)
    end)
  end

  def start_device(id, %DeviceManager.Device{} = device) do
    Logger.debug "Starting Histogram Device: #{id}"
    Registry.register(Cicada.DataManager.Registry, id, device)
    Supervisor.start_child(__MODULE__, [id])
  end

  def init(:ok) do
    Logger.info "Starting Histogram Device"
    children = [
      worker(Histogram.Device, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
