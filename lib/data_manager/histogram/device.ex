defmodule Cicada.DataManager.Histogram.Device do
  use Supervisor
  require Logger
  alias Cicada.DataManager.Histogram

  defmodule State do
    defstruct sensors: []
  end

  def start_link(name) do
    Supervisor.start_link(__MODULE__, :ok, name: name)
  end

  def records(name, id, map, keys \\ []) do
    map |> Map.to_list |> Enum.flat_map(fn({k, v} = metric) ->
      keys = keys ++ [Atom.to_string(k)]
      key = "#{id}::#{Enum.join(keys, "-")}"
      case k do
        other when other != :__struct__ ->
          case Histogram.Device.start_record(name, key) do
            :already_started -> :already_started
            _ -> :ok
          end
          Histogram.Device.Record.add(key, v)
          [key]
        other_map when v |> is_map -> records(id, v, keys)
        _ -> [nil]
      end
    end)
  end

  def snapshot() do
    Enum.reduce(Supervisor.which_children(__MODULE__), %{}, fn({id, child, type, module}, acc) ->
      values = Histogram.Device.Record.values(child)
      Map.put(acc, values.id, values)
    end)
  end

  def reset do
    Enum.each(Supervisor.which_children(__MODULE__), fn {id, child, type, module} ->
      Histogram.Device.Record.reset(child)
    end)
  end

  def start_record(name, id) do
    Logger.debug "Starting record: #{id}"
    Supervisor.start_child(name, [id])
  end

  def init(:ok) do
    Logger.info "Starting Device Histogram Record"
    children = [
      worker(Histogram.Device.Record, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def handle_call({:records, id, map, keys}, _from, state) do

    {:reply, :ok, state}
  end

end
