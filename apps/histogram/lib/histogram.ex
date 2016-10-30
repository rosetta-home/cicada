defmodule Histogram do
  use Application
  require Logger

  def start(_type, _opts) do
    Histogram.Supervisor.start_link
  end

  def new(id) do
    Histogram.Supervisor.start_record(id)
  end

  def snapshot() do
    Enum.reduce(Supervisor.which_children(Histogram.Supervisor), %{}, fn({id, child, type, module}, acc) ->
      values = Histogram.Record.values(child)
      Map.put(acc, values.id, values)
    end)
  end

  def reset do
    Enum.each(Supervisor.which_children(Histogram.Supervisor), fn {id, child, type, module} ->
      Histogram.Record.reset(child)
    end)
  end

end
