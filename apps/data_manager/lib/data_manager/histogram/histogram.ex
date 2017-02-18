defmodule DataManager.Histogram do
  use Supervisor
  require Logger
  alias DataManager.Histogram

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def new(id) do
    Histogram.start_record(id)
  end

  def snapshot() do
    Enum.reduce(Supervisor.which_children(__MODULE__), %{}, fn({id, child, type, module}, acc) ->
      values = Histogram.Record.values(child)
      Map.put(acc, values.id, values)
    end)
  end

  def reset do
    Enum.each(Supervisor.which_children(__MODULE__), fn {id, child, type, module} ->
      Histogram.Record.reset(child)
    end)
  end

  def start_record(id) do
    Logger.debug "Starting Histogram Record: #{id}"
    Supervisor.start_child(__MODULE__, [id])
  end

  def init(:ok) do
    Logger.info "Starting Histogram"
    children = [
      worker(Histogram.Record, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
