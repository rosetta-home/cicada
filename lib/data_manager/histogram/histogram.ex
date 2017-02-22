defmodule Cicada.DataManager.Histogram do
  use Supervisor
  require Logger
  alias Cicada.DataManager.Histogram

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def snapshot() do
    Enum.reduce(Supervisor.which_children(__MODULE__), %{}, fn({_id, child, _type, _module}, acc) ->
      values = Histogram.Device.Record.values(child)
      Map.put(acc, values.id, values)
    end)
  end

  def reset do
    Enum.each(Supervisor.which_children(__MODULE__), fn {_id, child, _type, _module} ->
      Histogram.Device.Record.reset(child)
    end)
  end

  def start_device(id) do
    Logger.debug "Starting Histogram Device: #{id}"
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
